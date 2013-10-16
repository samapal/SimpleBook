/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
 ***/
#import "PRPNibBasedTableViewCell.h"

@implementation PRPNibBasedTableViewCell

#pragma mark -
#pragma mark Cell generation

+ (NSString *)cellIdentifier {
  return NSStringFromClass([self class]);
}

+ (id)cellFromNib:(UINib *)nib {
	RNAssert([nib isKindOfClass:[UINib class]], @"入参 nib 类型不为 UINib");
	
	NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
	
	NSAssert2(([nibObjects count] > 0) &&
						[[nibObjects objectAtIndex:0] isKindOfClass:[self class]],
						@"Nib '%@' does not appear to contain a valid %@",
						[self nibName], NSStringFromClass([self class]));
	
	return [nibObjects objectAtIndex:0];
}

+ (id)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib {
  NSString *cellID = [self cellIdentifier];
  
  // 为了灵活操作是否使用 dequeueReusableCellWithIdentifier 缓存, 我们将 Identifier 的设置放到 .xib文件中,
  // 这样就可以通过给 xib 是否设置Identifier 来决定是否使用 dequeueReusableCellWithIdentifier 缓存cell了.
  // 在 xib 文件中的 Show the Attributes inspector 属性页面中 设置 Identifier 属性
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
  if (cell == nil) {
    cell = [self cellFromNib:nib];
  } else {
    
  }
  
  return cell;
}

#pragma mark -
#pragma mark Nib support

+ (UINib *)nib {
  NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
  UINib *nibObject =  [UINib nibWithNibName:[self nibName] bundle:classBundle];
  RNAssert(nibObject != nil, @"创建 nibObject 失败! 错误的nibName=%@", [self nibName]);
  return nibObject;
}

+ (NSString *)nibName {
  return [self cellIdentifier];
}

+(CGRect)viewFrameRectFromNib {
  NSArray *nibObjects = [[self nib] instantiateWithOwner:nil options:nil];
  UIView *view = [nibObjects objectAtIndex:0];
  return [view frame];
}
@end