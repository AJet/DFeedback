//
//  Copyright (c) 2017 Software Ambience Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------
// Creates NSDictionary much like a literal but allows nil values
extern NS_REQUIRES_NIL_TERMINATION NSDictionary* NSDictionaryWithKeysAndValues(id firstKey, ...);
