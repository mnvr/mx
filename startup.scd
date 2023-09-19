(Platform.userAppSupportDir +/+ "startup-superdirt.scd").load;
//s.options.inputStreamsEnabled_("00");

thisProcess.platform.recordingsDir = Platform.userHomeDir +/+ "Documents/Recordings";

(Platform.userAppSupportDir +/+ "startup-tiny-scope.scd").load;
(Platform.userAppSupportDir +/+ "startup-dirt-post.scd").load;

s.doWhenBooted { ~tinyScope.() }
