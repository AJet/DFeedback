//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFLinkLabel.h"
#import "DFLinkLabelDelegate.h"
#import "DFStyleSheet.h"

//-------------------------------------------------------------------------------------------------
@implementation DFLinkLabel
{
    NSFont* _font;
    NSColor* _textColor;
    NSTextStorage* _text;
    NSTextContainer* _textContainer;
    NSLayoutManager* _textLayoutManager;
    NSTrackingArea* _trackingArea;
    NSMutableArray* _linkRanges;
    NSMutableArray* _linkRectArrays;
    BOOL _isCursorSet;
}

//-------------------------------------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self != nil)
    {
        _text = [[NSTextStorage alloc] init];
        _textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(frameRect.size.width, FLT_MAX)];
        _textLayoutManager = [[NSLayoutManager alloc] init];
        [_textLayoutManager addTextContainer:_textContainer];
        [_text addLayoutManager:_textLayoutManager];
        _textContainer.lineFragmentPadding = 0.0;
        // this is necessary to match layout of the standard text field
        _textLayoutManager.typesetterBehavior = NSTypesetterBehavior_10_2_WithCompatibility;
        _linkRanges = [[NSMutableArray alloc] init];
        _linkRectArrays = [[NSMutableArray alloc] init];
    }
    return self;
}

//-------------------------------------------------------------------------------------------------
- (id)initWithTextField:(NSTextField*)textField
{
    self = [self initWithFrame:textField.frame];
    if (self != nil)
    {
        // save font and color
        _font = [textField.font retain];
        _textColor = [textField.textColor retain];
        // initialize value
        [self setStringValue:textField.stringValue];
    }
    return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_text release];
    [_textContainer release];
    [_textLayoutManager release];
    [_linkRanges release];
    [_linkRectArrays release];
    [_font release];
    [_textColor release];
    [_trackingArea release];
    [super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (BOOL)isFlipped
{
    return YES;
}

//-------------------------------------------------------------------------------------------------
- (void)appendTextWithPart:(NSString*)newPart
                attributes:(NSDictionary*)attrs
{
    NSAttributedString* attributedNewPart = [[[NSAttributedString alloc] initWithString:newPart attributes:attrs] autorelease];
    [_text appendAttributedString:attributedNewPart];
}


//-------------------------------------------------------------------------------------------------
- (void)setStringValue:(NSString*)value
{
    // reset
    _text.attributedString = [[[NSAttributedString alloc] init] autorelease];
    [_linkRanges removeAllObjects];
    [_linkRectArrays removeAllObjects];
    
    if (value != nil)
    {
        NSDictionary* normalTextAttrs = @{NSFontAttributeName : (_font != nil ? _font : DFLinkLabel_font),
                                          NSForegroundColorAttributeName : (_textColor != nil ? _textColor : DFLinkLabel_normalColor)};
        
        NSDictionary* linkTextAttrs = @{NSFontAttributeName : (_font != nil ? _font : DFLinkLabel_font),
                                        NSForegroundColorAttributeName : DFLinkLabel_linkColor,
                                        NSUnderlineStyleAttributeName : (DFLinkLabel_linkUnderlined ? @(NSUnderlinePatternSolid | NSUnderlineStyleSingle) : @(NSUnderlineStyleNone))};

        // split into attributed ranges
        NSUInteger openBracketLocation = NSNotFound;
        NSUInteger searchLocation = 0;
        NSUInteger valueLength = value.length;
        while (searchLocation < valueLength)
        {
            openBracketLocation = [value rangeOfString:@"["
                                               options:(NSStringCompareOptions)0
                                                 range:NSMakeRange(searchLocation, valueLength - searchLocation)].location;

            // string before open bracket
            NSString* newPiece = openBracketLocation == NSNotFound ?
            [value substringFromIndex:searchLocation] :
            [value substringWithRange:NSMakeRange(searchLocation, openBracketLocation - searchLocation)];
            [self appendTextWithPart:newPiece attributes:normalTextAttrs];
            
            if (openBracketLocation == NSNotFound)
            {
                break;
            }
            else
            {
                // link range
                searchLocation = openBracketLocation + 1;
                NSUInteger closeBracketLocation = [value rangeOfString:@"]"
                                                               options:(NSStringCompareOptions)0
                                                                 range:NSMakeRange(searchLocation, valueLength - searchLocation)].location;
                NSAssert(closeBracketLocation != NSNotFound, @"Link label error: open bracket unmatched with close bracket");

                NSString* linkPiece = [value substringWithRange:NSMakeRange(openBracketLocation + 1, closeBracketLocation - openBracketLocation - 1)];
                [_linkRanges addObject:[NSValue valueWithRange:NSMakeRange(_text.length, linkPiece.length)]];
                [self appendTextWithPart:linkPiece attributes:linkTextAttrs];
                
                
                searchLocation = closeBracketLocation + 1;
            }
        }
    }
    // redraw
    self.needsDisplay = YES;
}

//-------------------------------------------------------------------------------------------------
- (void)drawRect:(NSRect)dirtyRect
{
	NSRange glyphRange = [_textLayoutManager glyphRangeForTextContainer:_textContainer];
	[_textLayoutManager drawGlyphsForGlyphRange:glyphRange
                                        atPoint:NSMakePoint(self.bounds.origin.x, self.bounds.origin.y)];
}

//-------------------------------------------------------------------------------------------------
- (void)setFrameSize:(NSSize)value
{
    super.frameSize = value;
    // update container size
    _textContainer.containerSize = NSMakeSize(self.bounds.size.width, FLT_MAX);
    self.needsDisplay = YES;
}

//-------------------------------------------------------------------------------------------------
- (NSPoint)locationFromEvent:(NSEvent*)event
{
    NSPoint windowPoint = event.locationInWindow;
    NSPoint point = [self convertPoint:windowPoint fromView:nil];
    return point;
}

//-------------------------------------------------------------------------------------------------
- (void)mouseUp:(NSEvent*)event
{
    // respond to link click
    NSPoint location = [self locationFromEvent:event];
    NSUInteger linkIndex = [self hitTestLinkAtPoint:location];
    if (linkIndex != NSNotFound)
    {
        [self.delegate linkLabel:self didClickLinkNo:linkIndex];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)updateTrackingAreas
{
	if (_trackingArea != nil)
	{
		[self removeTrackingArea:_trackingArea];
		[_trackingArea release];
	}
	_trackingArea = [[NSTrackingArea alloc]
                     initWithRect:self.bounds
                     options:(NSTrackingAreaOptions)(NSTrackingActiveInKeyWindow | NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited)
                     owner:self
                     userInfo:nil];
	[self addTrackingArea:_trackingArea];
}

//-------------------------------------------------------------------------------------------------
- (void)resetCursorRects
{
    // rebuild cursor links
    for (NSUInteger i = 0; i < _linkRanges.count; ++i)
    {
        // get character range of the link
        NSRange linkRange = ((NSValue*)_linkRanges[i]).rangeValue;
        NSUInteger rectCount = 0;
        // measure set of bounding rects for the specified character range
        NSRectArray rects = [_textLayoutManager rectArrayForCharacterRange:linkRange
                                              withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0)
                                                           inTextContainer:_textContainer
                                                                 rectCount:&rectCount];
        // save the rects for hit testing and create cursor rects
        NSMutableArray* linkRects = [NSMutableArray arrayWithCapacity:rectCount];
        for (NSUInteger j = 0; j < rectCount; ++j)
        {
            NSRect rect = rects[j];
            [self addCursorRect:rect cursor:[NSCursor pointingHandCursor]];
            [linkRects addObject:[NSValue valueWithRect:rect]];
        }
        [_linkRectArrays addObject:linkRects];
    }
}

//-------------------------------------------------------------------------------------------------
- (NSUInteger)hitTestLinkAtPoint:(NSPoint)point
{
    // cycle of each link's rect array
    for (NSUInteger i = 0; i < _linkRectArrays.count; ++i)
    {
        NSArray* linkRects = _linkRectArrays[i];
        // cycle of rects within single link
        for (NSUInteger j = 0; j < linkRects.count; ++j)
        {
            NSRect linkRect = ((NSValue*)linkRects[j]).rectValue;
            // hit test
            if (NSPointInRect(point, linkRect))
            {
                // link found
                return i;
            }
        }
    }
    // link not found
    return NSNotFound;
}


@end
