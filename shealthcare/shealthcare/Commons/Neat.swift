//
//  Neat.swift
//  shealthcare
//
//  Created by SangWooKim on 06/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import Foundation

import UserNotifications


class Neat: NSObject {
    static let group = DispatchGroup()
    
    enum Weekday:Int {
        case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturdayz
    }
    
    static func active() {
        var startDate = Date()
        if let date = UserDefaults.standard.object(forKey: "DEFINE_NEAT_SERVICE") as? Date {
            startDate = date
        } else {
            UserDefaults.standard.set(startDate, forKey: "DEFINE_NEAT_SERVICE")
            UserDefaults.standard.synchronize()
            // 처음.
            if let date = startDate.addHour(1) {
                notification(type: "NEAT_FIRST",
                             hour:date.toString("HH").toInt(), min: date.toString("mm").toInt(),
                             body: "일상생활 활동량을 늘리는 것으로도 체중을 줄일 수 있어요!", repeats: false, userInfo: [:])
            }
        }
        
        let center = UNUserNotificationCenter.current()
        let group = DispatchGroup()
        group.enter()
        center.getPendingNotificationRequests(completionHandler: { requests in
            // Delete
            var temp:[String] = []
            for request in requests {
                if request.identifier.hasPrefix("NEAT_MAIN") {
                    temp.append(request.identifier)
                }
            }
            center.removeDeliveredNotifications(withIdentifiers: temp)
            center.removePendingNotificationRequests(withIdentifiers: temp)
            group.leave()
        })
        
        let calendar = Calendar.current
        var weekOfYear = calendar.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))
        // 4주치만 등록한다.
        for i in 0..<3 {
            if weekOfYear % 2 == 1 {
                debugPrint("홀수 주 \(weekOfYear)")
                notification(type: "NEAT_MAIN_1_" + i.toString() + "_",
                             weekday: Weekday.Monday.rawValue, weekOfYear: weekOfYear,
                             hour:08, min: 00,
                             body: "지하철•버스에서 서있기!\n일부러 서서 가면 앉아서 가는 것보다 2배 이상의 칼로리를 태울 수 있어요!", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_1_" + i.toString() + "_",
                             weekday: Weekday.Tuesday.rawValue, weekOfYear: weekOfYear,
                             hour:08, min: 00,
                             body: "TV 볼 때는 똑바로 앉아서!\n바른 자세로 앉는 것은 기대 앉는 것보다 1.5배 칼로리를 소모해요.", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_1_" + i.toString() + "_",
                             weekday: Weekday.Wednesday.rawValue, weekOfYear: weekOfYear,
                             hour:18, min: 30,
                             body: "마트에서 카트 대신 바구니!\n바구니를 들며 장보면 1.8배 칼로리를 소모하고 충동구매도 막을 수 있지요.", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_1_" + i.toString() + "_",
                             weekday: Weekday.Thursday.rawValue, weekOfYear: weekOfYear,
                             hour:11, min: 50,
                             body: "점심시간 짧은 산책!\n후식으로 카페 수다보다는 커피를 들고 산책하는 것도 좋은 시간을 보낼 수 있어요. 햇빛으로 비타민D 합성은 덤!", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_1_" + i.toString() + "_",
                             weekday: Weekday.Friday.rawValue, weekOfYear: weekOfYear,
                             hour:08, min: 00,
                             body: "물 들고 다니며 마시기!\n물 1리터를 마시면 50칼로리의 열량을 소비하는데 저장되는 칼로 리는 없어요! 생수 대신 카페인이 적은 차도 좋아요.", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_1_" + i.toString() + "_",
                             weekday: Weekday.Saturdayz.rawValue, weekOfYear: weekOfYear,
                             hour:10, min: 00,
                             body: "집에 강아지가 있나요?\n짧게 30분씩만 산책 나가도 일주일이면 3시간 반 걷게 되지요~ 행복한 강아지 건강한 주인!", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_1_" + i.toString() + "_",
                             weekday: Weekday.Sunday.rawValue, weekOfYear: weekOfYear,
                             hour:10, min: 00,
                             body: "집안일 할 때 신나는 음악과 함께!\n청소나 설거지를 할 때 신나는 음악을 틀어놓으면 나도 모르는 사이에 몸을 더 흔들거나 노래를 부르며 칼로리 소모가 많아져요.", repeats: true, userInfo: [:])
            } else {
                debugPrint("짝수 주 \(weekOfYear)")
                notification(type: "NEAT_MAIN_2_" + i.toString() + "_",
                             weekday: Weekday.Monday.rawValue, weekOfYear: weekOfYear,
                             hour:06, min: 30,
                             body: "한 정거장 전에 내려서 걸어가기!\n퇴근길 한 정거장 먼저 내려서 걷는 시간을 늘려보세요.", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_2_" + i.toString() + "_",
                             weekday: Weekday.Tuesday.rawValue, weekOfYear: weekOfYear,
                             hour:08, min: 00,
                             body: "일상생활 활동량을 늘리는 것으로도 체중을 줄일 수 있어요!", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_2_" + i.toString() + "_",
                             weekday: Weekday.Wednesday.rawValue, weekOfYear: weekOfYear,
                             hour:08, min: 00,
                             body: "엘리베이터 이용하지 않기!\n계단 오르내리기는 생각보다 칼로리 소모가 많답니다. 수영과 소 모량이 비슷해요.", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_2_" + i.toString() + "_",
                             weekday: Weekday.Thursday.rawValue, weekOfYear: weekOfYear,
                             hour:07, min: 00,
                             body: "리모컨 없애기!\nTV 리모컨 없이 채널을 바꾸기 위해 자주 왔다갔다하는 것도 칼로 리 소모가 꽤 많답니다.", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_2_" + i.toString() + "_",
                             weekday: Weekday.Friday.rawValue, weekOfYear: weekOfYear,
                             hour:08, min: 00,
                             body: "전화통화는 움직이면서!\n같은 시간 동안 제자리 걷기 운동을 하는 것과 효과가 같아요!", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_2_" + i.toString() + "_",
                             weekday: Weekday.Saturdayz.rawValue, weekOfYear: weekOfYear,
                             hour:10, min: 00,
                             body: "서서 빨래 개기!\n테이블/식탁에서 선 자세로 빨래를 개면 앉아서 개는 것보다 2배 많은 칼로리를 소모해요.", repeats: true, userInfo: [:])
                notification(type: "NEAT_MAIN_2_" + i.toString() + "_",
                             weekday: Weekday.Sunday.rawValue, weekOfYear: weekOfYear,
                             hour:10, min: 00,
                             body: "아이들과 함께 신체활동을!\n장난스런 몸싸움,공놀이 등은 비만을 부르는 TV시청보다 2배 이상의 칼로리 소모!가족간 화목은 덤!", repeats: true, userInfo: [:])
            }
            weekOfYear = weekOfYear + 1
            if weekOfYear > 52 {
                weekOfYear = 1
            }
        }
    }
    

    static func notification(type:String, weekday:Int = -1, weekOfYear:Int = -1, hour:Int, min:Int, body:String, repeats:Bool, userInfo:[AnyHashable : Any]) {
        if Global.pushNoti == false {
            return
        }
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.body = body
        if Global.soundNoti {
            content.sound = .default
        }
//        content.badge = 1
        content.userInfo = userInfo
        
        var dateComponents = DateComponents()
        if weekOfYear > -1 {
            dateComponents.weekOfYear = weekOfYear
        }
        dateComponents.hour = hour
        dateComponents.minute = min + 1
        if weekday > -1 {
            dateComponents.weekday = weekday
        }
        
        let identifier = String(format: "%@_%d_%d_%d%d", type, weekday, weekOfYear, hour, min)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let err = error {
                print(err.localizedDescription)
            }
        }
    }
}

