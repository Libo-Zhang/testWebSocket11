//
//  HT_SDManagerVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/21.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_SDManagerVC.h"
#import "HT_FPlayDevice.h"
#import "HT_FPlaySongsModel.h"
#import "HT_FPlayManager.h"
#import "HT_FPlayResModel.h"
#import "JSONModel.h"
#import <objc/runtime.h>
typedef NS_ENUM(NSInteger, HYBJSONModelDataType) {
    kHYBJSONModelDataTypeObject    = 0,
    kHYBJSONModelDataTypeBOOL      = 1,
    kHYBJSONModelDataTypeInteger   = 2,
    kHYBJSONModelDataTypeFloat     = 3,
    kHYBJSONModelDataTypeDouble    = 4,
    kHYBJSONModelDataTypeLong      = 5,
};
@interface HT_SDManagerVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableview;
//@property (nonatomic, strong) NSMutableArray *songList;
@property (nonatomic, strong) HT_FPlayDevice *device;

@end

@implementation HT_SDManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //self.songList = [NSMutableArray array];
    self.device = [HT_FPlayManager getInsnstance].currentDevice;
    NSLog(@"%@ %@",self.device.ipAddress,self.device.dname);
    
    self.tableview = [[UITableView alloc]init];
    self.tableview.frame = CGRectMake(0, 100, 300, 300);
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.tableview];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData{
    [[HT_FPlayManager getInsnstance].SDSongList removeAllObjects];
    __weak typeof (self)weakself = self;
    [self.device.connect_near sendMessage:401 WithotherParams:@[@(0)] WithSongList:nil];
    self.device.connect_near.nearReturnMessageBlock = ^(NSString *message){
        NSLog(@"message%@",message);
        
        NSString *actionStr = [message substringWithRange:NSMakeRange(8, 3)];
        if ([actionStr isEqualToString:@"402"]) {
            NSArray *array = [message componentsSeparatedByString:@"songs"];
            NSString *str = array.lastObject;
            NSString *str2 = [str substringWithRange:NSMakeRange(1, str.length - 2 )];;
            NSLog(@"songs %@",str2);
            NSData *data = [str2 dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *dictiona = [[NSMutableDictionary alloc] init];
            NSMutableString *str3 = [str2 mutableCopy];
            NSMutableString *str4 = [[str3 stringByReplacingOccurrencesOfString:@"{" withString:@"{\"" ] mutableCopy];
            NSMutableString *str5 = [[str4 stringByReplacingOccurrencesOfString:@":" withString:@"\":" ] mutableCopy];
            NSMutableString *str6 =[[str5 stringByReplacingOccurrencesOfString:@"," withString:@",\"" ] mutableCopy];
            NSMutableString *str7 =[[str6 stringByReplacingOccurrencesOfString:@"id:" withString:@"id\":" ] mutableCopy];
            NSMutableString *str8 =[[str7 stringByReplacingOccurrencesOfString:@"\"{" withString:@"{" ] mutableCopy];
            NSMutableString *str9 =[[str8 stringByReplacingOccurrencesOfString:@"\"://" withString:@"://" ] mutableCopy];
     
            
            NSArray *arr = [weakself dictionaryWithJsonString:str9];
            NSLog(@"%@",arr);
            for (NSDictionary *dic in arr) {
                HT_FPlaySongsModel *model = [HT_FPlaySongsModel new];
                [model setValuesForKeysWithDictionary:dic];
                NSMutableArray *resmuArr = [NSMutableArray array];
                HT_FPlayResModel *resModel = [HT_FPlayResModel new];
                for (NSDictionary *dic in model.res) {
                    [resModel setValuesForKeysWithDictionary:dic];
                    [resmuArr addObject:resModel];
                }
                model.res = resmuArr;
                [[HT_FPlayManager getInsnstance].SDSongList addObject:model];
                
                [weakself.tableview reloadData];
            }
            NSLog(@"%@",error);
           // NSLog(@"%@",d);
        }
    };
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [HT_FPlayManager getInsnstance].SDSongList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    HT_FPlaySongsModel *model = [HT_FPlayManager getInsnstance].SDSongList[indexPath.row];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = model.name;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HT_FPlaySongsModel *songmodel = [HT_FPlayManager getInsnstance].SDSongList[indexPath.row];
    NSMutableArray *resArr = [NSMutableArray array];
    for (HT_FPlayResModel *model in songmodel.res) {
        NSDictionary *resdic = [self dictionaryWithModel:model];
        [resArr addObject:resdic];
    }
    //HT_FPlayResModel *res =;
   NSMutableDictionary *dic = [[self dictionaryWithModel:songmodel] mutableCopy];
    [dic removeObjectForKey:@"res"];
    [dic setValue:[resArr copy] forKey:@"res"];
   // [HT_FPlayManager getInsnstance].songListIndex = indexPath.row;
    [self.device.connect_near sendMessage:203 WithotherParams:nil WithSongList:@[dic]];
    
}



- (id )dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {return nil;}NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];NSError *err;
    //NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainerserror:&err];
    id dic  = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
/*!
  * @brief 把对象（Model）转换成字典
  * @param model 模型对象
  * @return 返回字典
  */
- (NSDictionary *)dictionaryWithModel:(id)model {
    if (model == nil) {
        return nil;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // 获取类名/根据类名获取类对象
    NSString *className = NSStringFromClass([model class]);
    id classObject = objc_getClass([className UTF8String]);
    
    // 获取所有属性
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(classObject, &count);
    
    // 遍历所有属性
    for (int i = 0; i < count; i++) {
        // 取得属性
        objc_property_t property = properties[i];
        // 取得属性名
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property)
                                                          encoding:NSUTF8StringEncoding];
        // 取得属性值
        id propertyValue = nil;
        id valueObject = [model valueForKey:propertyName];
        
        if ([valueObject isKindOfClass:[NSDictionary class]]) {
            propertyValue = [NSDictionary dictionaryWithDictionary:valueObject];
        } else if ([valueObject isKindOfClass:[NSArray class]]) {
            propertyValue = [NSArray arrayWithArray:valueObject];
        } else {
            
            propertyValue = [model valueForKey:propertyName];
        }
        [dict setObject:propertyValue forKey:propertyName];
    }
    return [dict copy];
}


@end
