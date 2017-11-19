@Echo OFF
REM	****************************
REM	This batch file is used to perpare the data (audio recordings) for language model training
REM     Author: Shaoqing Yu(Shawn)  14/01/2016
REM	****************************


echo step: 1  recordings2prompts starts
REM	****************************
REM	There are 6 steps in preparation process, this is the 1 step "recordings2prompts"
REM	****************************

REM	****************************
REM     if the folder "Dictionaries" does not exist, Create one
REM	****************************
IF NOT EXIST "%cd%\..\Dictionaries\" (mkdir "%cd%\..\Dictionaries\")

REM	****************************
REM	set up the environment varibles 
REM	****************************
pushd "%cd%"
cd ..
for /f %%i in ('dir "%cd%" /a:d /b /d') do (
  IF NOT DEFINED %%i (
	set %%i=%cd%\%%i\
  )
)
popd

set recordingFolder=D:\UoA\Engineering\Semester 2017 S2\Project\Audio

REM	****************************
REM	assign character set to utf-8
REM	****************************
chcp 28605>NUL

REM	****************************
REM	list all the recordings 
REM	****************************
Perl "%Perls%Recordings2Prompts.pl" "%recordingFolder%" .wav "%Dictionaries%\"

echo step: 1  recordings2prompts ends








echo step: 2  recordings2mfcs starts
REM	****************************
REM	There are 6 steps in preparation process, this is the 2 step "recordings2mfcs"
REM	****************************

REM	****************************
REM     if the folder "MFCs" does not exist, Create one
REM	****************************
IF NOT EXIST "%cd%\..\MFCs\" (mkdir "%cd%\..\MFCs\")

REM	****************************
REM	set up the environment varibles 
REM	****************************

pushd "%cd%"
cd ..
for /f %%i in ('dir "%cd%" /a:d /b /d') do (
  IF NOT DEFINED %%i (
	set %%i=%cd%\%%i\
  )
)
popd

REM	****************************
REM     create train code script (Script.scp) with a filter suffix "wav" in %MFCs%
REM	****************************
Perl "%Perls%ScriptGenerater.pl" "%recordingFolder%" wav "%MFCs%\"

REM	****************************
REM	assign character set to utf-8
REM	****************************
REM     chcp 65001 >NUL

REM	****************************
REM     Generate MFC files by train code script
REM	****************************
"%Tools%HCopy" -T 1 -C "%Params%MFCs.conf" -S "%MFCs%script.scp"

echo step: 2  recordings2mfcs ends








echo step: 3  prompts2wordlist starts
REM	****************************
REM	There are 6 steps in preparation process, this is the 3 step "prompts2wordlist"
REM	****************************

REM	****************************
REM	set up the environment varibles 
REM	****************************
pushd "%cd%"
cd ..
for /f %%i in ('dir "%cd%" /a:d /b /d') do (
  IF NOT DEFINED %%i (
	set %%i=%cd%\%%i\
  )
)
popd

REM	****************************
REM	Generate word list file by Prompts.pmpt
REM	****************************
Perl "%Perls%prompts2wlist.pl" "%Dictionaries%Prompts.pmpt" "%Dictionaries%WordList.wlist"

echo step: 3  prompts2wordlist ends








echo step: 4  wordlist2dictionary starts
REM	****************************
REM	There are 6 steps in preparation process, this is the 4 step "wordlist2dictionary"
REM	****************************

REM	****************************
REM	set up the environment varibles 
REM	****************************
pushd "%cd%"
cd ..
for /f %%i in ('dir "%cd%" /a:d /b /d') do (
  IF NOT DEFINED %%i (
	set %%i=%cd%\%%i\
  )
)
popd

REM	****************************
REM	Generate a monophone list file with sp named "monophones1"
REM	****************************
"%Tools%HDMan" -m -w "%Dictionaries%WordList.wlist" -g "%Params%global.ded" -n "%Dictionaries%monophones1" -i -l HDMan.Log "%Dictionaries%dictionary" "%Dictionaries%lexicon.txt"
REM perl -pe "s/$/sp/ unless /^$|sil $|sp $/;" "%Dictionaries%lexicon.txt" > "%Dictionaries%dictionary"

REM	****************************
REM	Generate a monophone list file without sp named "monophones0"
REM	****************************
(type "%Dictionaries%monophones1" | findstr /v sp)>"%Dictionaries%monophones0"

echo step: 4  wordlist2dictionary ends








echo step: 5  prompts2Wordmlf starts
REM	****************************
REM	There are 6 steps in preparation process, this is the 5 step "prompts2Wordmlf"
REM	****************************

REM	****************************
REM     if the folder "MLFs" does not exist, Create one
REM	****************************
IF NOT EXIST "%cd%\..\MLFs\" (mkdir "%cd%\..\MLFs\")

REM	****************************
REM	set up the environment varibles 
REM	****************************
pushd "%cd%"
cd ..
for /f %%i in ('dir "%cd%" /a:d /b /d') do (
  IF NOT DEFINED %%i (
	set %%i=%cd%\%%i\
  )
)
popd

REM	****************************
REM	Generate word level MLF file by Prompts.pmpt
REM	****************************
Perl "%Perls%prompts2mlf.pl" "%MLFs%WordMLF.mlf" "%Dictionaries%Prompts.pmpt"

echo step: 5  prompts2Wordmlf ends









echo step: 6  wordmlf2phonemlf starts
REM	****************************
REM	There are 6 steps in preparation process, this is the 6 step "wordmlf2phonemlf"
REM	****************************

REM	****************************
REM     if the folder "MLFs" does not exist, Create one
REM	****************************
IF NOT EXIST "%cd%\..\MLFs\" (mkdir "%cd%\..\MLFs\")

REM	****************************
REM	set up the environment varibles 
REM	****************************
pushd "%cd%"
cd ..
for /f %%i in ('dir "%cd%" /a:d /b /d') do (
  IF NOT DEFINED %%i (
	set %%i=%cd%\%%i\
  )
)
popd

REM	****************************
REM	assign character set to utf-8
REM	****************************
REM     chcp 65001 >NUL

REM	****************************
REM     create the phone level MLF file named PhoneMLF0.mlf PhoneMLF1.mlf
REM	****************************

"%Tools%HLEd" -l * -d "%Dictionaries%dictionary" -i "%MLFs%PhoneMLF0.mlf" "%Params%mkphones0.led" "%MLFs%WordMLF.mlf"
"%Tools%HLEd" -l * -d "%Dictionaries%dictionary" -i "%MLFs%PhoneMLF1.mlf" "%Params%mkphones1.led" "%MLFs%WordMLF.mlf"

echo step: 6  wordmlf2phonemlf ends



@Echo OFF
REM	****************************
REM	This batch file is used to train the language model
REM     Author: Shaoqing Yu(Shawn)  01/02/2016
REM	****************************

REM	****************************
REM     if the folder "HMMs" does not exist, Create one
REM	****************************

IF NOT EXIST "%cd%\..\HMMs\" (mkdir "%cd%\..\HMMs\")

REM	****************************
REM	set up the environment varibles 
REM	****************************
pushd "%cd%"
cd ..
for /f %%i in ('dir "%cd%" /a:d /b /d') do (
  IF NOT DEFINED %%i (
	set %%i=%cd%\%%i\
  )
)
popd

REM	****************************
REM     Generate evaluation script in %Evaluations% from %MFCs%
REM	****************************
Perl "%Perls%Script2Train.pl" "%MFCs%script.scp" "%HMMs%train.scp"

REM	****************************
REM	assign character set to utf-8
REM	****************************
REM     chcp 65001 >NUL

REM	****************************
REM	make "%HMMs%"%HMMs%hmm0""
REM	****************************
REM if not exist "%HMMs%"%HMMs%hmm0"" (mkdir "%HMMs%hmm0")
REM "%Tools%HCompV" -C "%Params%HMMs.conf" -f 0.01 -m -S "%HMMs%train.scp" -M "%HMMs%hmm0" proto

REM	****************************
REM	make "%HMMs%hmm1"-3 based on "%HMMs%hmm0"
REM	****************************
if not exist "%HMMs%hmm1" (mkdir "%HMMs%hmm1")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFs%PhoneMLF0.mlf" -t 250.0 150.0 1000.0 -S "%HMMs%train.scp" -H "%HMMs%hmm0/macros" -H "%HMMs%hmm0/hmmdefs" -M "%HMMs%hmm1" "%Dictionaries%monophones0"

if not exist "%HMMs%hmm2" (mkdir "%HMMs%hmm2")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFs%PhoneMLF0.mlf" -t 250.0 150.0 1000.0 -S "%HMMs%train.scp" -H "%HMMs%hmm1/macros" -H "%HMMs%hmm1/hmmdefs" -M "%HMMs%hmm2" "%Dictionaries%monophones0"

if not exist "%HMMs%hmm3" (mkdir "%HMMs%hmm3")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFs%PhoneMLF0.mlf" -t 250.0 150.0 1000.0 -S "%HMMs%train.scp" -H "%HMMs%hmm2/macros" -H "%HMMs%hmm2/hmmdefs" -M "%HMMs%hmm3" "%Dictionaries%monophones0"

REM	****************************
REM	make "%HMMs%hmm5"-7 based on "%Params%sil.hed"
REM	****************************
if not exist "%HMMs%hmm5" (mkdir "%HMMs%hmm5")
"%Tools%HHEd" -H "%HMMs%hmm4/macros" -H "%HMMs%hmm4/hmmdefs" -M "%HMMs%hmm5" "%Params%sil.hed" "%Dictionaries%monophones1"

if not exist "%HMMs%hmm6" (mkdir "%HMMs%hmm6")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFs%PhoneMLF1.mlf" -t 250.0 150.0 1000.0 -S "%HMMs%train.scp" -H "%HMMs%hmm5/macros" -H "%HMMs%hmm5/hmmdefs" -M "%HMMs%hmm6" "%Dictionaries%monophones1"

if not exist "%HMMs%hmm7" (mkdir "%HMMs%hmm7")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFs%PhoneMLF1.mlf" -t 250.0 150.0 1000.0 -S "%HMMs%train.scp" -H "%HMMs%hmm6/macros" -H "%HMMs%hmm6/hmmdefs" -M "%HMMs%hmm7" "%Dictionaries%monophones1"

REM	****************************
REM	Re-aligning the training data 
REM	****************************
"%Tools%HVite" -l * -o SWT -b SENT-END -C "%Params%HMMs.conf" -a -H "%HMMs%hmm7/macros" -H "%HMMs%hmm7/hmmdefs" -i "%MLFs%AlignedMLF.mlf" -m -t 250.0 150.0 1000.0 -y lab -I "%MLFs%WordMLF.mlf" -S "%HMMs%train.scp" "%Dictionaries%dictionary" "%Dictionaries%monophones1"> HVite.log

REM	****************************
REM	make "%HMMs%hmm8"-9 based on a %MLFs%AlignedMLF.mlf
REM	****************************
if not exist "%HMMs%hmm8" (mkdir "%HMMs%hmm8")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFs%AlignedMLF.mlf" -t 250.0 150.0 1000.0 -S "%HMMs%train.scp" -H "%HMMs%hmm7/macros" -H "%HMMs%hmm7/hmmdefs" -M "%HMMs%hmm8" "%Dictionaries%monophones1"

if not exist "%HMMs%hmm9" (mkdir "%HMMs%hmm9")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFs%AlignedMLF.mlf" -t 250.0 150.0 1000.0 -S "%HMMs%train.scp" -H "%HMMs%hmm8/macros" -H "%HMMs%hmm8/hmmdefs" -M "%HMMs%hmm9" "%Dictionaries%monophones1"

REM	****************************
REM	make "%HMMs%hmm10"
REM	****************************
"%Tools%HLEd" -n "%Dictionaries%triphones1" -l * -i "%MLFs%TriphoneMLF.mlf" "%Params%mktri.led" "%MLFs%AlignedMLF.mlf"

Perl "%Perls%maketrihed.pl" "%Dictionaries%monophones1" "%Dictionaries%triphones1" "%Params%\"

if not exist "%HMMs%hmm10" (mkdir "%HMMs%hmm10")
"%Tools%HHEd" -H "%HMMs%hmm9/macros" -H "%HMMs%hmm9/hmmdefs" -M "%HMMs%hmm10" "%Params%mktri.hed" "%Dictionaries%monophones1"

REM	****************************
REM	make "%HMMs%hmm11"-12, as well as statistic file stats
REM	****************************
if not exist "%HMMs%hmm11" (mkdir "%HMMs%hmm11")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFS%triphoneMLF.mlf" -t 250.0 150.0 1000.0 -S "%HMMs%train.scp" -H "%HMMs%hmm10/macros" -H "%HMMs%hmm10/hmmdefs" -M "%HMMs%hmm11" "%Dictionaries%triphones1" 

if not exist "%HMMs%hmm12" (mkdir "%HMMs%hmm12")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFS%triphoneMLF.mlf" -t 250.0 150.0 1000.0 -s "%HMMs%stats" -S "%HMMs%train.scp" -H "%HMMs%hmm11/macros" -H "%HMMs%hmm11/hmmdefs" -M "%HMMs%hmm12" "%Dictionaries%triphones1"

"%Tools%HDMan" -b sp -n "%Dictionaries%FullPhoneList" -g "%Params%mktriphones.ded" -l HDMan.Log "%Dictionaries%tri-dictionary" "%Dictionaries%lexicon.txt"

type NUL > "%Dictionaries%FullPhoneListAdded"
type "%Dictionaries%monophones0" >> "%Dictionaries%FullPhoneListAdded"
type "%Dictionaries%FullPhoneList" >> "%Dictionaries%FullPhoneListAdded"
Perl "%Perls%MergeFullPhoneList.pl" "%Dictionaries%FullPhoneListAdded" "%Dictionaries%FullPhoneListMerged"
Perl "%Perls%EditTree.pl" "%Params%tree.hed" "%HMMs%stats" "%Dictionaries%FullPhoneListMerged" "%Dictionaries%tiedlist" "%HMMs%trees" 

REM	****************************
REM	make "%HMMs%hmm13"-15
REM	****************************
if not exist "%HMMs%hmm13" (mkdir "%HMMs%hmm13")
"%Tools%HHEd" -H "%HMMs%hmm12/macros" -H "%HMMs%hmm12/hmmdefs" -M "%HMMs%hmm13" "%Params%tree.hed" "%Dictionaries%triphones1"

if not exist "%HMMs%hmm14" (mkdir "%HMMs%hmm14")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFS%triphoneMLF.mlf"  -t 250.0 150.0 3000.0 -S "%HMMs%train.scp" -H "%HMMs%hmm13/macros" -H "%HMMs%hmm13/hmmdefs" -M "%HMMs%hmm14" "%Dictionaries%tiedlist"

if not exist "%HMMs%hmm15" (mkdir "%HMMs%hmm15")
"%Tools%HERest" -C "%Params%HMMs.conf" -I "%MLFS%triphoneMLF.mlf"  -t 250.0 150.0 3000.0 -S "%HMMs%train.scp" -H "%HMMs%hmm14/macros" -H "%HMMs%hmm14/hmmdefs" -M "%HMMs%hmm15" "%Dictionaries%tiedlist"



@Echo OFF
REM	****************************
REM	This batch file is used to evaluate the language model
REM     Author: Shaoqing Yu(Shawn)  14/01/2016
REM	****************************


echo step: 1  recordings2mfcs starts
REM	****************************
REM	There are 3 steps in preparation process, this is the 1 step "recordings2mfcs"
REM	****************************

REM	****************************
REM     if the folder "MFCs" does not exist, Create one
REM	****************************
IF NOT EXIST "%cd%\..\MFCs\" (mkdir "%cd%\..\MFCs\")

REM	****************************
REM	set up the environment varibles 
REM	****************************

pushd "%cd%"
cd ..
for /f %%i in ('dir "%cd%" /a:d /b /d') do (
  IF NOT DEFINED %%i (
	set %%i=%cd%\%%i\
  )
)
popd

set recordingFolder=D:\UoA\Engineering\Semester 2017 S2\Project\Audio

REM	****************************
REM     create train code script (Script.scp) with a filter suffix "wav" in %MFCs%
REM	****************************
Perl "%Perls%ScriptGenerater.pl" "%recordingFolder%" wav "%MFCs%\"

REM	****************************
REM	assign character set to utf-8
REM	****************************
REM     chcp 65001 >NUL

REM	****************************
REM     Generate MFC files by train code script
REM	****************************
"%Tools%HCopy" -T 1 -C "%Params%MFCs.conf" -S "%MFCs%script.scp"

echo step: 1  recordings2mfcs ends









echo step: 2  grammar2wordnet starts
REM	****************************
REM	There are 3 steps in preparation process, this is the 2 step "grammar2wordnet"
REM	****************************

REM	****************************
REM	set up the environment varibles 
REM	****************************
pushd "%cd%"
cd ..
for /f %%i in ('dir "%cd%" /a:d /b /d') do (
  IF NOT DEFINED %%i (
	set %%i=%cd%\%%i\
  )
)
popd

REM	****************************
REM     create word network file WordNet.wdnet by WordNets/HParse
REM	****************************
"%Tools%HParse" "%Grammars%grammar.gram" "%Grammars%WordNet.wdnet"
echo step: 2  grammar2wordnet ends






echo step: 3  recordingstest starts
REM	****************************
REM	There are 3 steps in preparation process, this is the 3 step "recordingstest"
REM	****************************

REM	****************************
REM     if the folder "Evaluations" does not exist, Create one
REM	****************************
IF NOT EXIST "%cd%\..\Evaluations\" (mkdir "%cd%\..\Evaluations\")

REM	****************************
REM     if the folder "MLFs" does not exist, Create one
REM	****************************
IF NOT EXIST "%cd%\..\MLFs\" (mkdir "%cd%\..\MLFs\")

REM	****************************
REM	set up the environment varibles 
REM	****************************
pushd "%cd%"
cd ..
for /f %%i in ('dir "%cd%" /a:d /b /d') do (
  IF NOT DEFINED %%i (
	set %%i=%cd%\%%i\
  )
)
popd

REM	****************************
REM     Generate evaluation script in %Evaluations% from %MFCs%
REM	****************************
Perl "%Perls%Script2Train.pl" "%MFCs%script.scp" "%Evaluations%evaluation.scp"

REM	****************************
REM	Recognize the recordings on evaluation.scp and then output the transcript "RecMLF.mlf"
REM	****************************
"%Tools%HVite" -o ST -H -C "%Params%HMMs.conf" "%HMMs%hmm15/macros" -H "%HMMs%hmm15/hmmdefs" -S "%Evaluations%evaluation.scp" -l * -T 4 -i "%MLFs%RecMLF.mlf" -w "%Grammars%WordNet.wdnet" -p 0.0 -s 5.0 "%Dictionaries%dictionary" "%Dictionaries%tiedlist"> HVite.log

("%Tools%HResults" -I "%MLFs%WordMLF.mlf" "%Dictionaries%tiedlist" "%MLFs%RecMLF.mlf")> "%Evaluations%result.txt"

echo step: 3  recordingstest ends

pause & exit
