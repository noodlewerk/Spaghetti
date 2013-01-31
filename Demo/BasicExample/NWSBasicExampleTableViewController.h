//
//  NWSBasicExampleTableViewController.h
//  Spaghetti
//
//  Created by Bruno Scheele on 5/28/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NWSBackend.h"

@interface NWSBasicExampleTwitterMessage : NSObject
@property (nonatomic) NSString *sender;
@property (nonatomic) NSString *text;
@property (nonatomic) NSDate *date;
@end

@interface NWSBasicExampleBackend : NWSBackend
+ (NWSBasicExampleBackend *)shared;
@end

@interface NWSBasicExampleTableViewController : UITableViewController
@end
