#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <netdb.h>
#import <arpa/inet.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CommonCrypto/CommonDigest.h>
#import "PascalImports.h"

#import "TERRA_Utils.h"
#import "TERRA_EAGLView.h"


void showAlert(char *message) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                    message:[NSString stringWithUTF8String:message]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

bool isSocialFrameworkAvailable()
{
    static BOOL available = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        available = NSClassFromString(@"SLComposeViewController") != nil;        
    });
    return available;
}

CGRect GetScreenBounds() {
   CGRect bounds = [UIScreen mainScreen].bounds;
//    return bounds;

    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        bounds.size = CGSizeMake(bounds.size.height, bounds.size.width);
    }
    return bounds;
}

BOOL isiPad()
{
    return (IS_IPAD() == YES);
}

void getModelType(char *name)
{
    size_t size;
    // set 'oldp' parameter to NULL to get the size of the data returned so we can allocate appropriate amount of space
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    // get the platform name
    sysctlbyname("hw.machine", name, &size, NULL, 0);
}

char* resolveHost(char *host)
{
    struct hostent *remoteHostEnt = gethostbyname(host);
    if (remoteHostEnt==NULL)
        return NULL;
    if (remoteHostEnt->h_addr_list[0]==NULL)
        return NULL;
    struct in_addr *remoteInAddr = (struct in_addr *) remoteHostEnt->h_addr_list[0];
    char* remoteAddr = inet_ntoa(*remoteInAddr); 
    return remoteAddr;
}

void vibrate()
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

void iPhoneLog(char *s)
{
    NSLog(@"%s", s);
}

AVAudioPlayer *audioOpen(char *name)
{
	AVAudioPlayer *audioPlayer;
		
	NSURL *url = [NSURL fileURLWithPath: [NSString stringWithFormat:@"%@/%s", [[NSBundle mainBundle] resourcePath], name]];
	NSLog(@"opening music file: %@", url);
	NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	audioPlayer.numberOfLoops = -1;
	
	if (audioPlayer != nil)
	   audioPlayer.volume = 0.25;

	return audioPlayer;
}

void audioPlay(AVAudioPlayer *audioPlayer)
{
    if (audioPlayer== NULL)
        return;
	[audioPlayer play];
}

void audioStop(AVAudioPlayer *audioPlayer)
{
    if (audioPlayer== NULL)
        return;
	[audioPlayer stop];
}

void audioClose(AVAudioPlayer *audioPlayer)
{
    if (audioPlayer== NULL)
        return;
	[audioPlayer release];
    audioPlayer = NULL;
}

void audioSetVolume(AVAudioPlayer *audioPlayer, float value)
{
    if (audioPlayer== NULL)
        return;
	audioPlayer.volume = value;
}


int fileExists(char *name)
{
	FILE* f;
	//NSLog(@"Opening %s", name);
	f = fopen(name, "rb");
	if (f)
	{
		//NSLog(@"ok");
		fclose(f);
		return 1;
	}
	else 
	{
		//NSLog(@"failed");
		return 0;
	}

}

int getCurrentOrientation() {
    //Obtaining the current device orientation
    UIDeviceOrientation orientation;
    orientation = [[UIDevice currentDevice] orientation];
    
    NSLog(@"Detected orientation %i", orientation);
    int result;
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:	result = 0; break;
        case UIDeviceOrientationLandscapeLeft:	result = 1; break;
        case UIDeviceOrientationLandscapeRight:	result = 2; break;
        case UIDeviceOrientationPortraitUpsideDown:	result = 3; break;
        default: result = -1; break;
    }
    
    NSLog(@"Returning %i", result);
    return result;
}

NSUserDefaults *prefs = NULL;

void setPrefString(char* key, char* data)
{
    NSLog(@"Saving string %s=%s", key, data);
	if (prefs == NULL)
		prefs = [NSUserDefaults standardUserDefaults];
	NSString *name = [NSString stringWithFormat:@"%s", key];
	NSString *value = [NSString stringWithFormat:@"%s", data];
	[prefs setObject:value forKey:name];
}

void savePref(char* key, char* data)
{
    NSLog(@"Saving prefers");
	if (prefs == NULL)
		return;
	[prefs synchronize];
    NSLog(@"Saved!");
}

void getPrefString(char* key, char* dest)
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *name = [NSString stringWithFormat:@"%s", key];
	if ([prefs objectForKey:name] != nil) 
	{
		NSString *value = [prefs stringForKey:name];
		strcpy(dest, [value UTF8String]);
	}
	else
	{
		*dest = 0;
	}
    
   NSLog(@"loaded string %s, value %s", key, dest);

}

void openAppStore(char *appid)
{
    NSString *myURL;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) 
    {   // here you go with iOS 7
        myURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%s", appid];            
    }
    else
    {
        myURL = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%s", appid];        
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:myURL]];
}
