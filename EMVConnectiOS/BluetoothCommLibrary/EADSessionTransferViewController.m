/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    View controller to allow transferring data to and from an accessory form the UI.
 */


#import "EADSessionTransferViewController.h"
#import "EADSessionController.h"

@interface EADSessionTransferViewController ()

@property(nonatomic) uint32_t totalBytesRead;
@property(nonatomic, strong) IBOutlet EAAccessory *accessory;
@property(nonatomic, strong) IBOutlet UILabel *receivedBytesCountLabel;
@property(nonatomic, strong) IBOutlet UITextField *stringToSendText;
@property(nonatomic, strong) IBOutlet UITextField *hexToSendText;

@end

@implementation EADSessionTransferViewController

// send test string to the accessory
- (IBAction)sendStringButtonPressed:(id)sender;
{
    if ([_stringToSendText isFirstResponder]) {
        [_stringToSendText resignFirstResponder];
    }

    char buf[7];
    
    buf[0] = (char)22;
    buf[1] = (char)79;
    buf[2] = (char)80;
    buf[3] = (char)78;
    buf[4] = (char)23;
    buf[5] = (char)-88;
    buf[6] = (char)-87;

    if (buf)
    {
        uint32_t len = (uint32_t)strlen(buf) + 1;
        [[EADSessionController sharedController] writeData:[NSData dataWithBytes:buf length:len]];
    }
    
    char buf2[23];
    
    buf2[0] = (char)22;
    buf2[1] = (char)68;
    buf2[2] = (char)83;
    buf2[3] = (char)80;
    buf2[4] = (char)48;
    buf2[5] = (char)49;
    buf2[6] = (char)51;
    buf2[7] = (char)67;
    buf2[8] = (char)111;
    buf2[9] = (char)110;
    buf2[10] = (char)101;
    buf2[11] = (char)99;
    buf2[12] = (char)116;
    buf2[13] = (char)97;
    buf2[14] = (char)110;
    buf2[15] = (char)100;
    buf2[16] = (char)111;
    buf2[17] = (char)46;
    buf2[18] = (char)46;
    buf2[19] = (char)46;
    buf2[20] = (char)23;
    buf2[21] = (char)6;
    buf2[22] = (char)46;
    
    if (buf2)
    {
        uint32_t len2 = (uint32_t)strlen(buf2) + 1;
        [[EADSessionController sharedController] writeData:[NSData dataWithBytes:buf2 length:len2]];
    }
}

// Interpret a UITextField's string at a sequence of hex bytes and send those bytes to the accessory
- (IBAction)sendHexButtonPressed:(id)sender;
{
    if ([_hexToSendText isFirstResponder]) {
        [_hexToSendText resignFirstResponder];
    }

    const char *buf = [[_hexToSendText text] UTF8String];
    NSMutableData *data = [NSMutableData data];
    if (buf)
    {
        uint32_t len = (uint32_t)strlen(buf);

        char singleNumberString[3] = {'\0', '\0', '\0'};
        uint32_t singleNumber = 0;
        for(uint32_t i = 0 ; i < len; i+=2)
        {
            if ( ((i+1) < len) && isxdigit(buf[i]) && (isxdigit(buf[i+1])) )
            {
                singleNumberString[0] = buf[i];
                singleNumberString[1] = buf[i + 1];
                sscanf(singleNumberString, "%x", &singleNumber);
                uint8_t tmp = (uint8_t)(singleNumber & 0x000000FF);
                [data appendBytes:(void *)(&tmp) length:1];
            }
            else
            {
                break;
            }
        }

        [[EADSessionController sharedController] writeData:data];
    }
}

// send 10K of data to the accessory.
- (IBAction)send10KButtonPressed:(id)sender
{
#define STRESS_TEST_BYTE_COUNT 10000
    NSLog(@"send10KButtonPressed");
    uint8_t buf[STRESS_TEST_BYTE_COUNT];
    for(int i = 0; i < STRESS_TEST_BYTE_COUNT; i++) {
        buf[i] = (i & 0xFF);  // fill buf with incrementing bytes;
    }

	[[EADSessionController sharedController] writeData:[NSData dataWithBytes:buf length:STRESS_TEST_BYTE_COUNT]];
}

#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // watch for the accessory being disconnected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    // watch for received data from the accessory
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceived:) name:EADSessionDataReceivedNotification object:nil];

    EADSessionController *sessionController = [EADSessionController sharedController];

    _accessory = [sessionController accessory];
    [self setTitle:[sessionController protocolString]];
    [sessionController openSession];
    _totalBytesRead = 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // remove the observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EADSessionDataReceivedNotification object:nil];

    EADSessionController *sessionController = [EADSessionController sharedController];

    [sessionController closeSession];
//    _accessory = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Internal

- (void)_accessoryDidDisconnect:(NSNotification *)notification
{
    if ([[self navigationController] topViewController] == self)
    {
        EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
        if ([disconnectedAccessory connectionID] == [_accessory connectionID])
        {
            [[self navigationController] popViewControllerAnimated:YES];

        }
    }
}

// Data was received from the accessory, real apps should do something with this data but currently:
//    1. bytes counter is incremented
//    2. bytes are read from the session controller and thrown away
- (void)_sessionDataReceived:(NSNotification *)notification
{
    EADSessionController *sessionController = (EADSessionController *)[notification object];
    uint32_t bytesAvailable = 0;

    while ((bytesAvailable = (uint32_t)[sessionController readBytesAvailable]) > 0) {
        NSData *data = [sessionController readData:bytesAvailable];
        if (data) {

            _totalBytesRead = _totalBytesRead + bytesAvailable;
        }
    }

    [_receivedBytesCountLabel setText:[NSString stringWithFormat:@"Bytes Received from Session: %u", (unsigned int)_totalBytesRead]];
}

@end
