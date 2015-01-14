**ProjectFileTool**

This command line tool parses your xcodeproj file to extract information about the files included in your build phase.

source files are considered to be ones with these extensions
(although this would be trivially easy to change)

NSArray *interestingExtensions=@[@"xib",@"m",@"storyboard",@"swift"];

**Synopsis**

ProjectFileTool [--help | --version |-c -xcproj xcodeproject [-targets targets] [-showtargets]

**Description**

Parse the xcodeproject file to manage included files

the options are as follows:

--help
output this help file

-c run as command line tool (rather than cocoa app)

-xcproj specify path of xcodeproject file

-targets specify comma limited list of targets to parse for files (default is all targets)

-showtargets output a list of target names

**Examples**

ProjectFileTool -xcproj path/To/project.xcodeproj

output source files included in project.xcodeproj


ProjectFileTool -xcproj path/To/project.xcodeproj -targets target1,target2

output source files included in project.xcodeproj which are in target1 or target2