//
//  EM_First_ViewController.m
//  Emoticon
//
//  Created by thanhhaitran on 2/5/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "EM_First_ViewController.h"

#import "TFHpple.h"

#import "XMLReader.h"

#define BANNER_TYPE kBanner_Portrait_Bottom

#define ratio 0.5

#define sideRatio 0.2

@interface EM_First_ViewController ()<UITableViewDataSource, UITableViewDelegate>

{
    NSMutableArray * dataList, * menuList, * sideMenuList;
    
    int count;
    
    IBOutlet UICollectionView * collectionView;
    
    NSString * url, * tempIndexPath;
    
    UIView * menu, * sideMenu;
    
    IBOutlet UIButton * cover;
    
    UIImage * tempImage;
    
    UIImageView * preview;
    
    BOOL isShort;
    
    CGRect start;
}

@end

@implementation EM_First_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    count = 1;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[AVHexColor colorWithHexString:@"#FFFFFF"]}];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7)
    {
        self.navigationController.navigationBar.barTintColor = [AVHexColor colorWithHexString:@"#4BABE4"];
        self.navigationController.navigationBar.translucent = NO;
    }
    else
    {
        self.navigationController.navigationBar.tintColor = [AVHexColor colorWithHexString:@"#4BABE4"];
    }
    
    UIBarButtonItem * menuB = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(didPressMenu)];
    self.navigationItem.leftBarButtonItem = menuB;
    
    UIBarButtonItem * share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressShare)];
    self.navigationItem.rightBarButtonItem = share;
    
    [collectionView registerNib:[UINib nibWithNibName:@"EM_Cells" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
    
    dataList = [NSMutableArray new];
    
    sideMenuList = [[NSMutableArray alloc] initWithArray:@[@"Save",@"Copy",@"Share",@"Close"]];
    
    __block  EM_First_ViewController * weakSelf = self;
    
    [collectionView addFooterWithBlock:^{
        
        [weakSelf didLoadMore];
        
    }];
    
    menu = [self returnView];
    
    sideMenu = [self returnSideMenu];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":@"https://dl.dropboxusercontent.com/s/b8kx3kzha96x8tw/Facemoticon.plist",@"overrideError":@(1),@"overrideLoading":@(1),@"host":self} withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSError *error, BOOL isValidated) {
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError * er = nil;
        NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                     options:XMLReaderOptionsProcessNamespaces
                                                       error:&er];
        
        NSMutableDictionary * option = [[XMLReader recursionRemoveTextNode:dict] mutableCopy];
        
        [self didPrepareData:[option[@"plist"][@"dict"][@"key"] boolValue]];
        
        isShort = [option[@"plist"][@"dict"][@"key"] boolValue];
        
    }];
    
    cover.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    preview = [self returnImage:CGRectMake(15, (screenHeight - (screenWidth - (screenWidth * sideRatio)) - 30) / 2 - 15 , (screenWidth - (screenWidth * sideRatio)) - 30 , (screenWidth - (screenWidth * sideRatio)) - 30)];
    
    [[StartAds sharedInstance] didShowBannerAdsWithInfor:@{@"host":self,@"Y":@(screenHeight - 64 - 50)} andCompletion:^(BannerEvent event, NSError *error, id bannerAd) {
        switch (event)
        {
            case AdsDone:
            {
                collectionView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
            }
                break;
            case AdsFailed:
            {
                collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }
                break;
            case AdsWillPresent:
            {
                
            }
                break;
            case AdsWillLeave:
            {
                
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didPrepareData:(BOOL)isShow
{
    self.title = [NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"][0][@"title"];

    url = [NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"][0][@"cat"];
    
    menuList = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"]];
    
    [self didRequestData];
}

- (void)didPressShare
{
    [[FB shareInstance] startShareWithInfo:@[@"Plenty of emotion stickers for your message and chatting, have fun!",@"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100",[UIImage imageNamed:@"facemo"]] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
        
    }];
}

- (IBAction)didPressCover:(id)sender
{
    if([self.view.subviews containsObject:sideMenu])
    {
        [self didPressSideMenu];
    }
    else
    {
        [self didPressMenu];
    }
}

- (UIView*)returnView
{
    UIView * mem = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][0];
    
    ((UITableView *)[self withView:mem tag:11]).delegate = self;
    
    ((UITableView *)[self withView:mem tag:11]).dataSource = self;

    return mem;
}

- (UIView*)returnSideMenu
{
    UIView * mem = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][3];
    
    ((UITableView *)[self withView:mem tag:12]).delegate = self;
    
    ((UITableView *)[self withView:mem tag:12]).dataSource = self;
    
    return mem;
}

- (UIImageView*)returnImage:(CGRect)frame
{
    UIImageView * mem = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][4];

    mem.frame = frame;

    return mem;
}

- (void)didPressSideMenu
{
    BOOL isMenu = [self.view.subviews containsObject:sideMenu];
    
    if(!isMenu)
    {
        sideMenu.frame = CGRectMake(screenWidth, (screenHeight - 200) / 2 - 44, screenWidth * sideRatio, 200);
        
        [self.view addSubview:sideMenu];
    }

    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = sideMenu.frame;
        
        rect.origin.x += isMenu ? screenWidth * sideRatio : - screenWidth * sideRatio;
        
        sideMenu.frame = rect;
        
        collectionView.userInteractionEnabled = isMenu;
        
    } completion:^(BOOL finished) {
        
        if (finished && isMenu && sideMenu.frame.origin.x != screenWidth * sideRatio)
        {
            [sideMenu removeFromSuperview];
            [cover removeFromSuperview];
            [self didChangeImagePosition:start isBack:NO];
        }
        else
        {
            [self.view insertSubview:cover belowSubview:sideMenu];
        }
        
    }];
}

- (void)didPressMenu
{
    BOOL isMenu = [self.view.subviews containsObject:menu];

    if(!isMenu)
    {
        menu.frame = CGRectMake( - screenWidth * ratio, (screenHeight - 200) / 2 - 44, screenWidth * ratio, 200);
        
        [self.view addSubview:menu];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = menu.frame;
        
        rect.origin.x += isMenu ? - screenWidth * ratio : screenWidth * ratio;
        
        menu.frame = rect;
        
        collectionView.userInteractionEnabled = isMenu;
        
    } completion:^(BOOL finished) {
        
        if (finished && isMenu && menu.frame.origin.x != 0)
        {
            [menu removeFromSuperview];
            [cover removeFromSuperview];
        }
        else
        {
            [self.view insertSubview:cover belowSubview:menu];
        }

    }];
}

- (void)didLoadMore
{
    count ++;
    
    [self didRequestData];
}

- (void)didRequestData
{
    [self showSVHUD:@"Loading" andOption:0];

    if(count == 1)
    {
        [dataList removeAllObjects];
    }
    
    NSURL * requestUrl = [NSURL URLWithString:[NSString stringWithFormat:url, count]];
    
    NSString * cc = [NSString stringWithFormat:@"%i",count + 100];
    
    dispatch_queue_t imageQueue = dispatch_queue_create([cc UTF8String],NULL);
    
    dispatch_async(imageQueue, ^{
        
        NSError* error = nil;
        
        NSData* htmlData = [NSData dataWithContentsOfURL:requestUrl options:NSDataReadingUncached error:&error];
        
//        NSLog(@"%@",[NSString stringWithUTF8String:[htmlData bytes]]);
        
        TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
        
        NSString *pathQuery = !isShort ? [self.title isEqualToString:@"Fun"] ? @"//div[@class='sticker-icons-container']" : @"//div[@class='mdCMN05Img']/img" : @"//div[@class='sticker-icons-container']";
        
//        NSString *pathQuery = @"//div[@class='sticker-icons-container']";
        
        NSArray *nodes = [parser searchWithXPathQuery:pathQuery];
        
        for (TFHppleElement *element in nodes)
        {
            if(!element.hasChildren)
            {
                [dataList addObject:@{@"image":[element objectForKey:@"src"]}];
                continue;
            }
            
            for(TFHppleElement *child in element.children)
            {
                for(TFHppleElement * c in child.children)
                {
                    if([c objectForKey:@"src"])
                    {
                        [dataList addObject:@{@"image":[c objectForKey:@"src"]}];
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [collectionView reloadData];
            
            [collectionView footerEndRefreshing];
            
            [self hideSVHUD];

            if(count == 1)
                
                [collectionView setContentOffset:CGPointZero animated:NO];
            
        });
    });
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableView.tag == 11 ? menuList.count : sideMenuList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"menu"];
    
    if(!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][1];
    }
    
    if(_tableView.tag == 11)
    {
        ((UILabel*)[self withView:cell tag:11]).text = menuList[indexPath.row][@"title"];
        
        ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#4BABE4"];

        [((UIView*)[self withView:cell tag:12]) withBorder:@{@"Bcorner":@(0),@"Bwidth": @(1.5) ,@"Bhex":@"#4BABE4"}];
        
        if([menuList[indexPath.row][@"title"] isEqualToString:self.title])
        {
            ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#D6544E"];
            
            ((UILabel*)[self withView:cell tag:11]).alpha = 0.3;
            
            [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
                
                ((UILabel*)[self withView:cell tag:11]).alpha = 1;
                
            } completion:nil];
        }
    }
    else
    {
        ((UILabel*)[self withView:cell tag:11]).text = sideMenuList[indexPath.row];
        
        ((UILabel*)[self withView:cell tag:11]).textAlignment = NSTextAlignmentCenter;
        
        ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#4BABE4"];
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(_tableView.tag == 11)
    {
        if([menuList[indexPath.row][@"title"] isEqualToString:self.title])
        {
            [self didPressMenu];
            
             return;
        }
        
        count = 1;
        
        self.title = menuList[indexPath.row][@"title"];
        
        [_tableView reloadData];
        
        url = menuList[indexPath.row][@"cat"];
        
        [self didRequestData];
        
        [self didPressMenu];
    }
    else
    {
        switch(indexPath.row)
        {
            case 0:
            {
                UIImageWriteToSavedPhotosAlbum(tempImage,self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)(dataList[[tempIndexPath intValue]][@"image"]));
            }
                break;
            case 1:
            {
                UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
                appPasteBoard.persistent = YES;
                [appPasteBoard setImage:tempImage];
            }
                break;
            case 2:
            {
                [[FB shareInstance] startShareWithInfo:@[@"Plenty of emotion stickers for your message and chatting, have fun!", @"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100", tempImage] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {

                    }];
            }
                break;
                case 3:
            {
                
            }
                break;
            default:
                break;
        }
        
        if(indexPath.row != 3)
        {
            if(![self getValue:@"detail"])
            {
                [self addValue:@"1" andKey:@"detail"];
            }
            else
            {
                int k = [[self getValue:@"detail"] intValue] + 1 ;

                [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"detail"];
            }

            if([[self getValue:@"detail"] intValue] % 4 == 0)
            {
                [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
            }
        }
        
        [self didPressCover:nil];
    }
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    [((UIImageView*)[self withView:cell tag:11]) sd_setImageWithURL:[NSURL URLWithString:dataList[indexPath.item][@"image"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    [((UIImageView*)[self withView:cell tag:11]) withBorder:@{@"Bcorner":@(0),@"Bwidth": indexPath.item % 2 != 0 ? @(1.5) : @(0),@"Bhex": indexPath.item % 2 != 0 ? @"#4BABE4" : @"#FFFFFF"}];
    
    NSArray * data = [System getFormat:@"key=%@" argument:@[dataList[indexPath.item][@"image"]]];
    
    ((UIImageView*)[self withView:cell tag:12]).alpha = data.count == 0 ? 0 : 1.0;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(screenWidth / 3 - 0.0, screenWidth / 3 - 0.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *imageURL = [NSURL URLWithString:dataList[indexPath.item][@"image"]];
    
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    tempImage = image;
    
    tempIndexPath = [NSString stringWithFormat:@"%li",(long)indexPath.item];
    
    [self didPressSideMenu];
    
    UICollectionViewCell * cell = [_collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect windowRect = [cell convertRect:cell.bounds toView:nil];
    
    windowRect.origin.y -= 64;
    
    start = windowRect;
    
    [self didChangeImagePosition:windowRect isBack:YES];
}

- (void)showAds
{
    [[StartAds sharedInstance] didShowFullAdsWithInfor:@{} andCompletion:^(BannerEvent event, NSError *error, id bannerAd) {
        switch (event)
        {
            case AdsDone:
            {
                
            }
                break;
            case AdsFailed:
            {
                
            }
                break;
            case AdsWillPresent:
            {
                
            }
                break;
            case AdsWillLeave:
            {
                
            }
                break;
            default:
                break;
        }
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        [self showSVHUD:@"Photo not saved, try again later" andOption:2];
    }
    else
    {
        [self showSVHUD:@"Done" andOption:1];
        
        [System addValue:(__bridge NSString*)contextInfo andKey:(__bridge NSString*)contextInfo];
        
        [collectionView reloadData];
    }
}

-(void)didChangeImagePosition:(CGRect)rect isBack:(BOOL)back
{

    UIImageView * temp = [[UIImageView alloc] initWithFrame:rect];
    temp.backgroundColor = [self.title isEqualToString:@"Fun"] ? [AVHexColor colorWithHexString:@"#DDEFFA"] : [UIColor clearColor];
    temp.image = tempImage;
    
    if(back)
    {
        [self.view addSubview:preview];
        [self.view addSubview:temp];
    }
    
    CGRect destination = [preview convertRect:preview.bounds toView:nil];
    destination.origin.y -= 64;
    
    [UIView animateWithDuration:0.3 animations:^{
        if(back)
        {
            temp.transform = [self translatedAndScaledTransformUsingViewRect:back ? destination : rect fromRect: back ? rect : destination];
        }
        else
        {
            preview.transform = [self translatedAndScaledTransformUsingViewRect:back ? destination : rect fromRect: back ? rect : destination];
        }
    }
                     completion:^(BOOL finished){
                         if(back)
                         {
                             [temp removeFromSuperview];
                             preview.image = tempImage;
                             preview.backgroundColor = [self.title isEqualToString:@"Fun"] ? [AVHexColor colorWithHexString:@"#DDEFFA"] : [UIColor clearColor];
                         }
                         else
                         {
                             [preview removeFromSuperview];
                             preview = [self returnImage:CGRectMake(15, (screenHeight - (screenWidth - (screenWidth * sideRatio)) - 30) / 2 - 15 , (screenWidth - (screenWidth * sideRatio)) - 30 , (screenWidth - (screenWidth * sideRatio)) - 30)];
                         }
                         self.navigationItem.leftBarButtonItem.enabled = !back;
                     }];
}

- (CGAffineTransform)translatedAndScaledTransformUsingViewRect:(CGRect)viewRect fromRect:(CGRect)fromRect
{
    CGSize scales = CGSizeMake(viewRect.size.width/fromRect.size.width, viewRect.size.height/fromRect.size.height);
    CGPoint offset = CGPointMake(CGRectGetMidX(viewRect) - CGRectGetMidX(fromRect), CGRectGetMidY(viewRect) - CGRectGetMidY(fromRect));
    return CGAffineTransformMake(scales.width, 0, 0, scales.height, offset.x, offset.y);
}

- (void)pulse:(UIView*)view toSize: (float) value withDuration:(float) duration
{
    [UIView animateWithDuration:duration
                     animations:^{
                         CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                         pulseAnimation.duration = duration;
                         pulseAnimation.toValue = [NSNumber numberWithFloat:value];;
                         pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                         pulseAnimation.autoreverses = YES;
                         pulseAnimation.repeatCount = 1;
                         [view.layer addAnimation:pulseAnimation forKey:nil];
                     }
                     completion:^(BOOL finished)
     {
     }];
}

- (NSString *)uuidString
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

@implementation UIImage (AverageColor)

- (UIColor *)averageColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] == 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

@end

