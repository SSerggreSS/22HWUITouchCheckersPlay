//
//  ViewController.m
//  22HWTouchesCheckers
//
//  Created by Сергей on 22/09/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//

//Вот такой вот урок по тачам. Решил жесты и тачи в один урок не объединять, а относительно простой функционал тачей решил дополнить практическим примером :)
//
//Уровень супермен (остальных уровней не будет)
//
//1. Создайте шахматное поле (8х8), используйте черные сабвьюхи
//2. Добавьте балые и красные шашки на черные клетки (используйте начальное расположение в шашках)
//3. Реализуйте механизм драг'н'дроп подобно тому, что я сделал в примере, но с условиями:
//4. Шашки должны ставать в центр черных клеток.
//5. Даже если я отпустил шашку над центром белой клетки - она должна переместиться в центр ближайшей к отпусканию черной клетки.
//6. Шашки не могут становиться друг на друга
//7. Шашки не могут быть поставлены за пределы поля.
//
//Вот такое вот веселое практическое задание :)


#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic, readwrite) UIView *checkerForDragging;
@property (assign, nonatomic) CGPoint touchOffSet;

@property (weak, nonatomic) IBOutlet UIImageView *checkersBoard;

@property (strong, nonatomic) IBOutletCollection(BlackCell) NSArray *blackCells;

@property (strong, nonatomic) IBOutletCollection(Checker) NSArray *checkers;

@property (assign, nonatomic) CGPoint startPointDraggingChecker;

@property (assign, nonatomic) Boolean checkerBreaksRule;

@property (weak, nonatomic) UIAlertController *alertWorning;

@end

@implementation ViewController

- (instancetype) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
//when touched to screen
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    [self printPointCoordinateTouches:touches onView:self.view methodName:@"touchesBegan"];
    
    CGPoint pointOnMainView = [self getPointTouchFromTouches:touches inView:self.view];
    UIView *view = [self.view hitTest:pointOnMainView withEvent:event];
    
    //view not should wos main view and not should wos view for black cell
    if (![view isEqual:self.view] && view.tag != 1) {
        
        self.checkerForDragging = view;
        self.startPointDraggingChecker = view.center;
        
        [self.view bringSubviewToFront:self.checkerForDragging];
        
        CGPoint touchPoint = [self getPointTouchFromTouches:touches inView:self.checkerForDragging];
        
        self.touchOffSet = CGPointMake(CGRectGetMidX(self.checkerForDragging.bounds) - touchPoint.x,
                                       CGRectGetMidY(self.checkerForDragging.bounds) - touchPoint.y);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.checkerForDragging.transform = CGAffineTransformMakeScale(1.4, 1.4);
        }];
        
    } else {
        self.checkerForDragging = nil;
    }
}
//touch moving
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
        
        [self printPointCoordinateTouches:touches onView:self.view methodName:@"touchesMoved"];
    
    if (self.checkerForDragging) {
        
        CGPoint pointTouch = [self getPointTouchFromTouches:touches inView:self.view];
        
        CGPoint correction = CGPointMake(self.touchOffSet.x + pointTouch.x,
                                         self.touchOffSet.y + pointTouch.y);
        
        self.checkerForDragging.center = correction;
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
            
    BOOL isIntesection = NO;
    UIView *intersectionView;
    
    [self printPointCoordinateTouches:touches onView:self.view methodName:@"touchesEnded"];
    
    [self viewInDefaultState:self.checkerForDragging withAnimateDuration:0.3];
    
    if (!CGRectContainsRect(CGRectInset(self.checkersBoard.frame, 30.0f, 30.0f), self.checkerForDragging.frame)) {

        [UIView animateWithDuration:0.1 animations:^{
            self.checkerForDragging.center = self.startPointDraggingChecker;
        }];

        self.alertWorning = [UIAlertController alertControllerWithTitle:@"⚠️ATTENTION⚠️"
                                                                       message:@"You cannot go outside the board!❌"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"Ok"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];

        [self.alertWorning addAction:alertAction1];
        [self presentViewController:self.alertWorning animated:YES completion:nil];
    
        NSLog(@"alert");
        
    }
    
    for (Checker* checker in self.checkers) {

        if ((CGRectIntersectsRect(self.checkerForDragging.frame, checker.frame)) &&
            ![self.checkerForDragging isEqual:checker]) {
            
            self.checkerForDragging.center = self.startPointDraggingChecker;

        }

    }
    
    for (BlackCell *blackCell in self.blackCells) {
        
        if (CGRectIntersectsRect(blackCell.frame, self.checkerForDragging.frame)) {
            intersectionView = blackCell;
        }
    
}
    
    for (BlackCell *blackCell in self.blackCells) {
        if ([blackCell isEqual:intersectionView]) {
            
            [UIView animateWithDuration:0.3 animations:^{
                self.checkerForDragging.center = blackCell.center;
            }];
            isIntesection = YES;
            break;
        } else if (!CGRectIntersectsRect(self.checkerForDragging.frame, blackCell.frame) &&
                   ![blackCell isEqual:intersectionView]) {
            
            NSLog(@"!!!");
            [UIView animateWithDuration:0.3 animations:^{
                self.checkerForDragging.center = self.startPointDraggingChecker;
            }];
        }
    }
    
    if (!isIntesection) {
        NSLog(@"%@", isIntesection ? @"YES" : @"NO");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"⚠️ATTENTION⚠️"
                                                                           message:@"Сannot be placed on a white cage!❌"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        
            UIAlertAction *action =    [UIAlertAction actionWithTitle:@"Ok"
                                                             style:UIAlertActionStyleDefault
                                                           handler:nil];
        
            [alert addAction:action];
            [self presentViewController: alert animated:YES completion:nil];
        
    }
    
    self.checkerForDragging = nil;
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    
    [self printPointCoordinateTouches:touches onView:self.view methodName:@"touchesCancelled"];
    
    [self viewInDefaultState:self.checkerForDragging withAnimateDuration:0.3];
    
    self.checkerForDragging.center = self.startPointDraggingChecker;
    
    self.checkerForDragging = nil;
    
}

#pragma mark - Help function

- (void)printPointCoordinateTouches:(NSSet<UITouch *> *)touches onView:(UIView *)view methodName:(NSString *)methodName {
    
    NSMutableString *string = [[NSMutableString alloc] initWithString:methodName];
    
    for (UITouch * touch in touches) {
    
        CGPoint point = [touch locationInView:view];
        [string appendFormat:@" %@", NSStringFromCGPoint(point)];
    }
    
    NSLog(@"%@", string);
    
}

- (CGFloat)randomNumberFromZeroToOne {
    
    CGFloat randNumb = (float)(arc4random() % 256) / 255;
    
    return randNumb;
    
}

- (UIColor *)randomColor {
    
    CGFloat r = [self randomNumberFromZeroToOne];
    CGFloat g = [self randomNumberFromZeroToOne];
    CGFloat b = [self randomNumberFromZeroToOne];
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
    
}

- (CGPoint)getPointTouchFromTouches:(NSSet<UITouch *>*)touches inView:(UIView *)view {
    
    CGPoint point = [touches.anyObject locationInView:view];
    
    return point;
    
}

- (void)viewInDefaultState:(UIView *)view withAnimateDuration:(CGFloat)time {
    
    [UIView animateWithDuration:time animations:^{
        view.transform = CGAffineTransformIdentity;
        view.alpha = 1.0;
    }];
    
    
}

@end
