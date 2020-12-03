//
//  CZFilterIndexPath.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "CZFilterIndexPath.h"

@implementation CZFilterIndexPath
- (instancetype)initWithTab:(NSInteger)tab {
    return [self initWithTab:tab fRow:0 sRow:0 tRow:0];
}

- (instancetype)initWithTab:(NSInteger)tab fRow:(NSInteger)fRow {
    return [self initWithTab:tab fRow:fRow sRow:0 tRow:0];
}

- (instancetype)initWithTab:(NSInteger)tab fRow:(NSInteger)fRow sRow:(NSInteger)sRow {
    return [self initWithTab:tab fRow:fRow sRow:sRow tRow:0];
}

- (instancetype)initWithTab:(NSInteger)tab fRow:(NSInteger)fRow sRow:(NSInteger)sRow tRow:(NSInteger)tRow {
    CZFilterIndexPath *indexPath = [[CZFilterIndexPath alloc] init];
    indexPath.tab = tab;
    indexPath.fRow = fRow;
    indexPath.sRow = sRow;
    indexPath.tRow = tRow;
    return indexPath;
}

+ (instancetype)indexPathWithTab:(NSInteger)tab {
    return [self indexPathWithTab:tab fRow:0 sRow:0 tRow:0];
}

+ (instancetype)indexPathWithTab:(NSInteger)tab fRow:(NSInteger)fRow {
    return [self indexPathWithTab:tab fRow:fRow sRow:0 tRow:0];
}

+ (instancetype)indexPathWithTab:(NSInteger)tab fRow:(NSInteger)fRow sRow:(NSInteger)sRow {
    return [self indexPathWithTab:tab fRow:fRow sRow:sRow tRow:0];
}

+ (instancetype)indexPathWithTab:(NSInteger)tab fRow:(NSInteger)fRow sRow:(NSInteger)sRow tRow:(NSInteger)tRow {
      CZFilterIndexPath *indexPath = [[self alloc] initWithTab:tab fRow:fRow sRow:sRow tRow:tRow];
      return indexPath;
}

- (NSUInteger)hash {
    NSUInteger tabHash = _tab;
    NSUInteger fRowHash = _fRow;
    NSUInteger sRowHash = _sRow;
    NSUInteger tRowHash = _tRow;
    return tabHash ^ fRowHash ^ sRowHash ^ tRowHash;
}

- (BOOL)isEqual:(id)object {
    
    if (self == object) {
        return YES;
    }
    
    if ([self class] != [object class]) {
        return NO;
    }
    
    CZFilterIndexPath *targetIndexPath = (CZFilterIndexPath *)object;
    if (targetIndexPath.tab != self.tab) {
        return NO;
    }
    
    if (targetIndexPath.fRow != self.fRow) {
        return NO;
    }
    
    if (targetIndexPath.sRow != self.sRow) {
        return NO;
    }
    
    if (targetIndexPath.tRow != self.tRow) {
        return NO;
    }

    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    CZFilterIndexPath *copy = [[[self class] allocWithZone:zone] initWithTab:_tab
                                                                             fRow:_fRow
                                                                             sRow:_sRow
                                                                             tRow:_tRow];
    return copy;
}
@end
