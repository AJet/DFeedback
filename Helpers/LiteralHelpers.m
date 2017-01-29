//
//  Copyright (c) 2017 Software Ambience Corp. All rights reserved.
//

#import "LiteralHelpers.h"

//-------------------------------------------------------------------------------------------------
static NSUInteger const kStaticCapacity = 16;
static NSUInteger const kDynamicCapacityIncrement = 16;

//-------------------------------------------------------------------------------------------------
NSDictionary* NSDictionaryWithKeysAndValues(id firstKey, ...)
{
    va_list keyValueList;
    va_start(keyValueList, firstKey);
    
    __unsafe_unretained id staticKeys[kStaticCapacity];
    __unsafe_unretained id staticValues[kStaticCapacity];

    __unsafe_unretained id* dynamicKeys = NULL;
    __unsafe_unretained id* dynamicValues = NULL;
    
    // begin with static capacity at first
    NSUInteger resultCount = 0;
    NSUInteger currentCapacity = kStaticCapacity;
    BOOL isStaticCapacity = YES;
    __unsafe_unretained id* resultKeys = (__unsafe_unretained id*)staticKeys;
    __unsafe_unretained id* resultValues = (__unsafe_unretained id*)staticValues;

    for (id key = firstKey; key != nil; key = va_arg(keyValueList, id))
    {
        id value = va_arg(keyValueList, id);
        if (value != nil)
        {
            // add capacity if necessary
            if (resultCount == currentCapacity)
            {
                currentCapacity += kDynamicCapacityIncrement;
                // switch from static to dynamic allocation
                if (isStaticCapacity)
                {
                    dynamicKeys = (__unsafe_unretained id *)malloc(currentCapacity * sizeof(id));
                    dynamicValues = (__unsafe_unretained id *)malloc(currentCapacity * sizeof(id));
                    memcpy(dynamicKeys, staticKeys, kStaticCapacity * sizeof(id));
                    memcpy(dynamicValues, staticValues, kStaticCapacity * sizeof(id));
                    isStaticCapacity = NO;
                }
                // dynamic reallocation
                else
                {
                    dynamicKeys = (__unsafe_unretained id *)realloc(dynamicKeys, currentCapacity * sizeof(id));
                    dynamicValues = (__unsafe_unretained id *)realloc(dynamicValues, currentCapacity * sizeof(id));
                }
                // refresh resulting pointers
                resultKeys = dynamicKeys;
                resultValues = dynamicValues;
            }

            resultKeys[resultCount] = key;
            resultValues[resultCount] = value;
            ++resultCount;
        }
    }
    
    va_end(keyValueList);
    
    NSDictionary* result = [NSDictionary dictionaryWithObjects:resultValues forKeys:resultKeys count:resultCount];
    if (dynamicKeys != NULL)
    {
        free(dynamicKeys);
    }
    if (dynamicValues != NULL)
    {
        free(dynamicValues);
    }
    return result;
}
