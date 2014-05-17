# Script:         SegmentationChecking.praat

#=========================================================#
# Initial version, before commit to https://github.com/LearningToTalk/Segmentation/ 
#=========================================================#

# Author:		Mary Beckman			<mbeckman@ling.osu.edu>
# Affiliations:	Learning to Talk		<learningtotalk.org>
#			Ohio State University	<linguistics.osu.edu>
# Date: 		Started January 01, 2014; Beta version March ?, 2014
# Purpose:	Fill in here after talking with Hannele Nicholson, Rose Crooks, & Jamie Anderson

# To test:
# 1) Do all the exit functions work gracefully?
# 2) Does the insertion of <mute_on> and <mute_off> for older files work?
# 3) ...

#=========================================================#
# Subsequent version history ...
#=========================================================#


#### HERE decide whether to move this part into the startup_check_segmentation.praat file 

#=========================================================#
#  Global variables (other than those defined in startup section on basis of user input)             #
#=========================================================#

# Praat procedure.
procedure$ = "Checking segmentation"

# TextGrid tier numbers and tier names
tg_trial       = 1
tg_trial$      = "Trial"
tg_word        = 2
tg_word$       = "Word"
tg_context     = 3
tg_context$    = "Context"
tg_repetition  = 4
tg_repetition$ = "Repetition"
tg_notes       = 5
tg_notes$      = "SegmNotes"
tg_changes       = 6
tg_changes$      = "CheckNotes"

# Segmentation Log table columns
sl_segmenter  = 1
sl_segmenter$ = "Segmenter"
sl_startDate  = 2
sl_startDate$ = "StartDate"
sl_endDate    = 3
sl_endDate$   = "EndDate"
#sl_xmin       = 4
#sl_xmin$      = "ExperimentXMin"
sl_nTrials    = 4
sl_nTrials$   = "NumberOfTrials"
sl_segTrials  = 5
sl_segTrials$ = "NumberOfTrialsSegmented"

# Audio-Anonymization Log table columns
al_xmin  = 1
al_xmin$ = "XMin"
al_xmax  = 2
al_xmax$ = "XMax"

#### HERE the gist of the following should go into the startup_check_segmentation.praat file

#=========================================================#
#  Start-up section                                                                                                                    #
#=========================================================#

# [GET USER INPUT]
# Specify the following things, so that script can make an educated guess about
# which files to load, etc. 
#	1) checker
#	2) segmenter
#	3) location where checking is taking place (to determine tier2 drive name)
#	4) experimental task that elicited the recording and ...
#	5) test wave (e.g., "TimePoint1", "TimePoint2") of the recording 
beginPause ("'procedure$' - Initializing session, step 1.")
	# 1) Prompt the user to enter the checker's initials.
	comment ("Please enter your initials in the field below.")
  	word    ("Your initials", "")
	# 2) Prompt the user to enter the segmenter's initials.
	comment ("Please enter the initials of the segmenter below.")
  	word    ("Segmenters initials", "")
	# 3) Prompt the checker to specify where the checking is being done.
	comment ("Please specify what kind of machine you are using.")
		optionMenu ("Location", 2)
		option ("WaismanLab")
		option ("ShevlinHallLab")
		option ("Mac via VPN")
		option ("Other (Beckman)")
		option ("Developing (Beckman)")
		option ("Other (not Beckman)")
		option ("Mac rdc / l2t server")
	# 4) Prompt the checker to specify what type of recording it is -- i.e., "task".
	comment ("Please choose the experimental task of the recording.")
	optionMenu ("Task", 2)
		option ("NonWordRep")
		option ("RealWordRep")
		option ("GFTA")
	# 5) Prompt the checker to specify the testwave (i.e., the "TimePoint") of the data.
	comment ("Please specify the test wave of the recording.")
	optionMenu ("Testwave", 1)
		option ("TimePoint1")
		option ("TimePoint2")
		option ("TimePoint3")
		option ("Other")
	# 6) Prompt the checker to specify the participant ID of the data.
	comment ("Please enter the participant's 3-digit ID number in the field below.")
  	word    ("id number", "")
button = endPause ("Quit", "Continue", 2)
# Use the 'button' variable to determine what to do next.
if button == 1
	# If the checker must quit this checking session prematurely
	# (button = 1), exit the script.
	exit You have chosen to stop running the script for now.
endif
### Later we may want to change this to distinguish between quitting the session
### and proceeding to a non-canonical files arrangement?
# If the checker wants to proceed with these initials, location, etc., (button = 2)

# [RESEARCHER IDENTITY VARIABLES]
# 1) Set the value of the checkers_initials$ variable 
checkers_initials$ = your_initials$
# 2) The segmenters_initials$ variable should be now set. 
# segmenters_initials$ = segmenters_initials$

# [LOCAL FILE SYSTEM VARIABLES]
# 3) Use the value of the 'location$' variable to set up the drive$ and audio_drive$ variables.
if (location$ == "WaismanLab")
	drive$ = "L:/" 
	audio_drive$ = "L:/"
elsif (location$ == "ShevlinHallLab")
	drive$ = "//l2t.cla.umn.edu/tier2/"
	audio_drive$ = "//l2t.cla.umn.edu/tier2/"
elsif (location$ == "Mac via VPN")
	drive$ = "I:/"
	audio_drive$ = "/Volumes/tier2onUSB/"
elsif location$ == "Other (Beckman)"				
	drive$ = "/Volumes/tier2/"
	audio_drive$ = "/LearningToTalk/Tier2/"
elsif location$ == "Developing (Beckman)"
	drive$ = "/LearningToTalk/Tier2/"
	audio_drive$ = "/LearningToTalk/Tier2/"
elsif location$ == "Other (not Beckman)"	
	exit Contact Mary Beckman and your segmentation guru to request another location
endif

# 4) and 5) Use the task$ and testwave$ variables to set up the directory 
# path names under the drive$ and audio_drive$, beginning with ...
###### Unshared directories that are specific to the segmenter.
# The directory from where the ...SegmentationLog.txt file is read to make sure
# segmentation was in fact finished.
segmentLog_dir$ = drive$+"Segmenting/Segmenters/"+segmenters_initials$+"/Logs"+task$
# The directory from where the ...segm.TextGrid file is read to be checked.
textGrid_dir$ = drive$+"Segmenting/Segmenters/"+segmenters_initials$+"/Segmentation"+task$
###### Shared directories that will not be affected by the process of segmentation.
# The directory from where audio files are read.
audio_dir$ = audio_drive$+"DataAnalysis/"+task$+"/"+testwave$+"/Recordings/"
###### Shared directories that can be or will changed by the process of checking.
# The directory to where anonymized audio log files are written.
audioAnon_dir$ = drive$+"DataAnalysis/"+task$+"/"+testwave$+"/AudioAnonymizationLogs/"
# The directory to where the ...SegmentationLog.txt file is moved when segmentation
# is complete and has been checked.
sharedSegmentLog_dir$ = drive$+"DataAnalysis/"+task$+"/"+testwave$+"/SegmentationLogs/"
# The directory to where the ...segm.TextGrid file is moved when segmentation
# is complete and has been checked.
sharedTextGrid_dir$ = drive$+"DataAnalysis/"+task$+"/"+testwave$+"/SegmentationTextGrids/"

# [SEGMENTATION LOG FILE]
# Determine which .txt file in the 'segmentLog_dir$' directory has a filename that includes
#  the id number of the subject presently being segmented.
Create Strings as file list... logFile 'segmentLog_dir$'/'task$'_'id_number$'*.txt
n_logs = Get number of strings
# Check to see if the list is empty and if it is, exit with an error message. 
if ('n_logs' == 0)
	select Strings logFile
	Remove
	exit There seems to be no file for child 'id_number$' in 'segmentLog_dir$'
endif
# Otherwise, get the name of the file from the logFile Strings object. 
select Strings logFile
segmentLog_filename$ = Get string... 1
# Clean up
Remove
# Make string variables for the segmentation log's basename,
# filename, and filepath on the local filesystem, using the
segmentLog_basename$ = left$(segmentLog_filename$, length(segmentLog_filename$) - 4)
segmentLog_filepath$ = "'segmentLog_dir$'/'segmentLog_filename$'"
# Make the corresponding experimental_ID$ variable that need later.
experimental_ID$ = mid$(segmentLog_basename$, length(task$)+2, 9)
# Also make a name for the segmentation log Praat Table.
segmentLog_table$    = "'experimental_ID$'_SegmentLog"
# Read in the file.
Read Table from tab-separated file... 'segmentLog_filepath$'
select Table 'segmentLog_basename$'
Rename... 'segmentLog_table$'
# Get the values for the NumberOfTrials and the NumberOfTrialsSegmented. 
n_trials_total = Get value... 1 'sl_nTrials$'
n_trials_segmented = Get value... 1 'sl_segTrials$'
# Check to see if there are trials left to be segmented. 
if ('n_trials_segmented' < 'n_trials_total')
	# If there are trials left to be segmented clean up and exit.
	select Table 'segmentLog_table$'
	Remove
	exit Segmenter 'segmenters_initials$' has not finished segmenting the file for child 'id_number$'
endif
# Otherwise add a row and set it's values.
Append row
current_time$ = replace$(date$(), " ", "_", 0)
Set string value... 2 'sl_segmenter$' 'checkers_initials$'
Set string value... 2 'sl_startDate$' 'current_time$'
Set string value... 2 'sl_endDate$' 'current_time$'
Set numeric value... 2 'sl_nTrials$' 'n_trials_total'
Set numeric value... 2 'sl_segTrials$' 0

# [AUDIO FILE]
# Determine whether .WAV file exists in the 'audio_dir$' directory.
audio_filepath$ = "'audio_dir$'/'task$'_'experimental_ID$'.WAV"
audio_sound$  = "'experimental_ID$'_Audio"
audio_file_exists = fileReadable(audio_filepath$)
# If the file does not exists and we're on a Mac or UNIX system. 
if ('audio_file_exists' == 0) and (macintosh or unix)
	#  Check to see whether that's because we're on a Mac and there is a wav file instead.
 		audio_filepath$ = "'audio_dir$'/'task$'_'experimental_ID$'.wav"
		audio_file_exists = fileReadable(audio_filepath$)
endif
# If no audio file exists by either extension, then clean up and exit.
if ('audio_file_exists' == 0) 
	select Table 'segmentLog_table$'
	Remove
	exit There is no audio file in 'audio_dir$' for child 'id_number$'
endif
# Otherwise, read in the audio file, and rename it to the value of the
# 'audio_sound$' string variable.
Read from file... 'audio_filepath$'
Rename... 'audio_sound$'

# [SEGMENTATION TEXTGRID]
# Make string variables for the segmentation TextGrid's
# basename, filename, and filepath on the local filesystem.
textGrid_basename$ = "'task$'_'experimental_ID$'_'segmenters_initials$'segm"
textGrid_filename$ = "'textGrid_basename$'.TextGrid"
textGrid_filepath$ = "'textGrid_dir$'/'textGrid_filename$'"
textGrid_object$   = "'experimental_ID$'_Segmentation"
# Look for the segmentation TextGrid in the filesystem.
textGrid_exists = fileReadable(textGrid_filepath$)
# If it doesn't exist, clean up and exit. 
if (textGrid_exists == 0)
	select Table 'segmentLog_table$'
	plus Sound 'audio_sound$'
	Remove
	exit There is no file 'textGrid_filename$' in 'textGrid_dir$'
endif
# If the segmentation TextGrid exists on the local
# filesystem, read it in as a Praat TextGrid object, and
# then rename it according to the 'textGrid_object$' variable.
Read from file... 'textGrid_filepath$'
Rename... 'textGrid_object$'
# Duplicate the 5 original tiers at the bottom, with segmenters initials as suffix
select TextGrid 'textGrid_object$'
Duplicate tier... tg_trial 6 "'tg_trial''segmenters_initials$"
Duplicate tier... tg_word 7 "'tg_word''segmenters_initials$"
Duplicate tier... tg_context 8 "'tg_context''segmenters_initials$"
Duplicate tier... tg_repetition 9 "'tg_repetition''segmenters_initials$"
Duplicate tier... tg_notes 10 "'tg_notes''segmenters_initials$"
# Then add a points tier to record the checker's initials.
Insert point tier... 6 "Checked'checkers_initials$'"

# [AUDIO-ANONYMIZATION LOG]
# Make string variables for the audio-anonymization log's
# basename, filename, and filepath on the local filesystem.
audioLog_basename$ = "'task$'_'experimental_ID$'_'segmenters_initials$'audioLog"
audioLog_filename$ = "'audioLog_basename$'.txt"
audioLog_filepath$ = "'audioAnon_dir$'/'audioLog_filename$'"
audioLog_table$    = "'experimental_ID$'_AudioLog"
# Look for the audio-anonymization log on the local filesystem.
audioLog_exists = fileReadable(audioLog_filepath$)
# If it doesn't exist, clean up and exit.
if (audioLog_exists==0)
	select Table 'segmentLog_table$'
	plus Sound 'audio_sound$'
	plus TextGrid 'textGrid_object$'
	Remove
	exit There is no file 'audioLog_filename$' in 'audioAnon_dir$'
endif
# However, if the audio-anonymization log exists on the local
# filesystem, read it in as a Praat Table and then rename
# it according to the 'audioLog_table$' variable.
Read Table from tab-separated file... 'audioLog_filepath$'
select Table 'audioLog_basename$'
Rename... 'audioLog_table$'
# Sort the rows of the audio-anonymization log in
# ascending order of their XMin value.
select Table 'audioLog_table$'
Sort rows... 'al_xmin$'
# Anonymize the audio file on the basis of the already identified intervals
# to mute, after checking to make sure that those intervals are marked.
select Table 'audioLog_table$'
n_anonymizations = Get number of rows
# Count the number of <mute_off> labels. 
select TextGrid 'textGrid_object$'
n_mute_labels = Count labels... 11 <mute_off>
# Loop through the rows of the 'audioLog_table$' table. 
for anon to n_anonymizations
	# Get the time of the start and end of the interval to mute. 
 	select Table 'audioLog_table$'
	anon_xmin = Get value... 'anon' 'al_xmin$'
	anon_xmax = Get value... 'anon' 'al_xmax$'
	# Mute it. 
	select Sound 'audio_sound$'
	Set part to zero... 'anon_xmin' 'anon_xmax' at nearest zero crossing
	# If there are no mute labels, insert them now, as well. 
	if (n_mute_labels == 0)
		select TextGrid 'textGrid_object$'
		Insert point... 'tg_notes' 'anon_xmin' <mute_on>
		Insert point... 'tg_notes' 'anon_xmax' <mute_off>
	endif
endfor


#### HERE decide whether to move the "initialization" parts of the following 
#### into the startup_check_segmentation.praat file 

#===============================================#
#  Checking section                                                                                          #
#===============================================#

# [INITIALIZING]
# Open the audio object and the textgrid object in an Edit window. 
select Sound 'audio_sound$'
plus TextGrid 'textGrid_object$'
Edit
# Set up to loop through the intervals on the Trial tier in the TextGrid, by first
# setting a variable for the number.
select TextGrid 'textGrid_object$'
number_tg_intervals = Get number of intervals... 'tg_trial'
# Then initialize the number of intervals checked and number of trials checked.
no_intervals_checked = 0
no_trials_checked = 0

# [CHECKING]
#### Should this forloop be replaced with a whileloop, so that checking can be done 
#### in more than one session? 
# Loop through the intervals. 
for tg_interval_i from 1 to 'number_tg_intervals'
	select TextGrid 'textGrid_object$'
	tg_int_xmin = Get start point... 'tg_trial' 'tg_interval_i'
	tg_int_xmax = Get end point... 'tg_trial' 'tg_interval_i'
	tg_int_label$ = Get label of interval... 'tg_trial' 'tg_interval_i'
	if (tg_int_label$=="")
		tg_int_label$ = "between trials"
	endif
	editor TextGrid 'textGrid_object$'
		Zoom... 'tg_int_xmin' 'tg_int_xmax'
		beginPause ("'procedure$' for interval 'tg_interval_i' : 'tg_int_label$'.")
		endPause ("Abort checking", "Next interval", 2, 1)
	endeditor
#### HERE is how far Mary got when she last worked on it.   Here's where we want a way
#### to allow the checker to decide what things, if any, to correct, and then click on all 
#### of the relevant things in an expandable list, each of which then invokes the relevant
#### procedure. 

endfor 




#===============================================#
#  Procedure definitions                                                                                   #
#===============================================#

procedure anonymizeInterval
	# Clear the action-selection variable that controls how the script behaves 
	# within this block of code.
	mute_action = 0
	# Send the checker into a while-loop within which they have the 
	# option to do one of the following actions:
	#   1. Confirm the boundaries of the selection to be muted
	#   2. Update the boundaries of the selection to be muted
	#   3. Go back to the top-level selection menu
	in_mute_selection_loop = 1
	while (in_mute_selection_loop)
		# Get the xmin and xmax boundaries of the selection to be muted.
		editor TextGrid 'textGrid_object$'
			mute_selection_xmin = Get start of selection
			mute_selection_xmax = Get end of selection
			mute_selection_dur  = Get selection length
		endeditor
		# The selection can only be muted if it is an interval, - ie. has nonzero duration.
		# Check the duration of the to-be-muted selection.
		if (mute_selection_dur > 0)
			# If the duration of the to-be-muted selection is
			# greater than zero, ie. the selection is an interval
			# rather than a point, then zoom to this selection and
			# play it for the segmenter.
			# The xmin and xmax of the zoom window are determined by
			# the 'mute_selection_zoom_pad' variable.
			mute_selection_zoom_xmin = 'mute_selection_xmin' - 'mute_selection_zoom_pad'
			mute_selection_zoom_xmax = 'mute_selection_xmax' + 'mute_selection_zoom_pad'
			# Check that the xmin of the zoom window for the to-be-muted 
			# selection is not less than the xmin of the audio.
			if (mute_selection_zoom_xmin < audio_xmin)
				mute_selection_zoom_xmin = audio_xmin
			endif
			# Check that the xmax of the zoom window for the to-be-muted selection 
			# is not greater than the xmax of the audio.
			if (mute_selection_zoom_xmax > audio_xmax)
				mute_selection_zoom_xmax = audio_xmax
			endif
			# Zoom and play in the Editor window.
			editor TextGrid 'textGrid_object$'
				Zoom... mute_selection_zoom_xmin mute_selection_zoom_xmax
				Play... mute_selection_xmin mute_selection_xmax
			endeditor
			# Prompt the segmenter to confirm the selection to be muted.
			beginPause ("'procedure$' - Muting the selected interval.")
 				comment ("(1)	If this is the interval of the recording that you would")
				comment(" 	like to mute, click 'Mute'.")
				comment ("(2)	Otherwise, adjust the boundaries of the selection in")
				comment("	the Editor window, and then click 'Adjust'.")
			mute_action = endPause ("", "Mute", "Adjust", "Back", 2, 1)
			# Use the 'mute_action' variable to determine what happens next.
			if mute_action == 2
				# If the segmenter chooses to 'Mute selection'...
				# First, add the xmin and xmax of the mute-selection
				# to the Audio-Anonymization Log table.
   				select Table 'audioLog_table$'
				Append row
				n_anonymizations = Get number of rows
				Set numeric value... 'n_anonymizations' 'al_xmin$' 'mute_selection_xmin'
				Set numeric value... 'n_anonymizations' 'al_xmax$' 'mute_selection_xmax'

				# Second, mute the mute-selection in the audio Sound object.
				select Sound 'audio_sound$'
				Set part to zero... 'mute_selection_xmin' 'mute_selection_xmax' at nearest zero crossing

				# Third, insert notes on the notes tier marking the start and end 
				# of the muted selection.
				select TextGrid 'textGrid_object$'
				Insert point... 'tg_notes' 'mute_selection_xmin' <mute_on>
				Insert point... 'tg_notes' 'mute_selection_xmax' <mute_off>

				# Fourth, save the audio-anonymization log.
				select Table 'audioLog_table$'
				Save as tab-separated file... 'audioLog_filepath$'
				# Finally, break out of the 'mute selection' loop.
				in_mute_selection_loop = 0
			elsif mute_action == 3
				# If the checker chooses to 'Update boundaries',
				# stay in the 'mute selection' while-loop.
				in_mute_selection_loop = 1
			elsif mute_action == 4
				# If the checker chooses to go 'Back' to the top-level
				# selection menu, then break from the 'mute selection'
				# while-loop.
				in_mute_selection_loop = 0
			endif
		else
			# If the duration of the to-be-muted selection is
			# equal to zero, ie. the selection is a point rather
			# than an interval, then inform the segmenter that only
			# intervals can be muted, and prompt them to update 
			# the boundaries of the selection or go back to the 
			# top-level selection menu.
			beginPause ("'procedure$' - Warning 2: trying to mute a single point.")
				comment ("You're trying to mute a single point in the audio recording,")
				comment ("	rather than an interval.")
				comment ("To mute an interval of the audio recording, first highlight it")
				comment ("	in the Editor window, and then click 'Mute selection'.")
			mute_action = endPause ("", "Mute selection", "Back", 2, 1)
			if mute_action == 2
				# If the checker chooses to 'Mute selection', then
				# stay in the 'mute selection' while-loop.
				in_mute_selection_loop = 1
			elsif mute_action == 3
				# If the checker chooses to go 'Back' to the top-level selection menu, 
				# then break out of the 'mute selection' while-loop.
   				in_mute_selection_loop = 0
   			endif
   		endif
   	endwhile
endproc
