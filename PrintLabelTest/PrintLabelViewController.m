//
//  PrintLabelViewController.m
//  PrintLabelTest
//
//  Created by Mithlesh Jha on 19/10/16.
//  Copyright © 2016 Mithlesh Jha. All rights reserved.
//

#define kEntityTypeVial @"Vial"
#define kEntityTypeInventory @"Inventory"
#define kEntityTypeAliquot @"Aliquot"

#define kLabelKeyVialId @"Vial Id"
#define kLabelKeyInventoryId @"Inventory Id"
#define kLabelKeyAliquotId @"Aliquot Id"
#define kLabelKeyDescription @"Description"
#define kLabelKeyDate @"Date"



#import "PrintLabelViewController.h"

@interface PrintLabelViewController () {
    NSArray *entityTypes;
    
    NSMutableArray *queuedLabels;
}

@property (nonatomic, weak) IBOutlet UITableView *entityTypesTableView;
@property (nonatomic, weak) IBOutlet UITextField *tf1;
@property (nonatomic, weak) IBOutlet UITextField *tf2;
@property (nonatomic, weak) IBOutlet UITextField *tf3;

@property (nonatomic, weak) IBOutlet UILabel *queuedLabel;


@end

@implementation PrintLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    entityTypes = @[kEntityTypeVial, kEntityTypeInventory, kEntityTypeAliquot];
    
    queuedLabels = [NSMutableArray new];
    [self selectedEntityAtIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) selectedEntityAtIndex:(NSUInteger)index {
    
    // Reset queuedLabels
    [queuedLabels removeAllObjects];
    self.queuedLabel.text = nil;
    
    NSString *entityType = entityTypes[index];
    
    if ([entityType isEqualToString:kEntityTypeVial]) {
        self.tf1.placeholder = kLabelKeyVialId;
        self.tf2.placeholder = kLabelKeyDescription;
        self.tf3.placeholder = kLabelKeyDate;
    } else if ([entityType isEqualToString:kEntityTypeInventory]) {
        self.tf1.placeholder = kLabelKeyInventoryId;
        self.tf2.placeholder = kLabelKeyDescription;
        self.tf3.placeholder = kLabelKeyDate;
    } else if ([entityType isEqualToString:kEntityTypeAliquot]) {
        self.tf1.placeholder = kLabelKeyAliquotId;
        self.tf2.placeholder = kLabelKeyDescription;
        self.tf3.placeholder = kLabelKeyDate;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return entityTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = entityTypes[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectedEntityAtIndex:indexPath.row];
}

- (NSString*)base64EncodedString {
    
    NSMutableString *mStr = [NSMutableString new];
    
    for (NSDictionary *dictionary in queuedLabels) {
        [mStr appendFormat:@"^XA\
         ^FO20,20^BQ,2,10\
         ^FD%@,%@,%@^FS\
         ^XZ",
         dictionary[self.tf1.placeholder],
         dictionary[self.tf2.placeholder],
         dictionary[self.tf3.placeholder]];
    }
    
    NSString *string = mStr;
    if (string == nil)
        return nil;
    
    NSLog(@"**Original String\n%@\n",string);
    // Create NSData object
    NSData *nsdata = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    if ([base64Encoded characterAtIndex:base64Encoded.length - 1] == '=') {
        base64Encoded = [base64Encoded stringByReplacingOccurrencesOfString:@"=" withString:@"_"];
    }
    // Print the Base64 encoded string
    NSLog(@"Encoded: %@", base64Encoded);
    
    // NSData from the Base64 encoded str
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:base64Encoded options:0];
    
    // Decoded NSString from the NSData
    NSString *base64Decoded = [[NSString alloc]
                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    NSLog(@"Decoded: %@", base64Decoded);
    return base64Encoded;
}

- (void) printEncodedString:(NSString*)encodedString {
    if (!(encodedString.length > 0)) {
        NSLog(@"Error occurred in printing label with string %@", encodedString);
        return;
    }
    
    
    NSString *str = [NSString stringWithFormat:@"arrowhead://x-callback-url/zplcode?code=%@&x-success=printtest://", encodedString];
    NSLog(@"\n** Print URL**\n%@", str);
    
    NSURL *url = [NSURL URLWithString:str];
    if ([[UIApplication sharedApplication] canOpenURL:url])
        [[UIApplication sharedApplication] openURL:url];
    else {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Printer App Not Found" message:@"Please install printer app on your device to print label" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:NULL];
    }
}


- (IBAction)printAction:(id)sender {
    NSString *printString = [self base64EncodedString];
    [self printEncodedString:printString];
}

- (IBAction)addLabelAction:(id)sender {
    NSDictionary *dictionary = @{self.tf1.placeholder : self.tf1.text, self.tf2.placeholder : self.tf2.text, self.tf3.placeholder : self.tf3.text };
    [queuedLabels addObject:dictionary];
    
    self.tf1.text = @"";
    self.tf2.text = @"";
    self.tf3.text = @"";
    
    NSUInteger count = queuedLabels.count;
    self.queuedLabel.text = [NSString stringWithFormat:@"%lu %@ queued", (unsigned long)count, count > 1 ? @"labels" : @"label"];
}



@end
