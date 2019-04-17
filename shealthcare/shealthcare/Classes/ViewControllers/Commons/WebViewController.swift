//
//  WebViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 11/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import MKProgress

class WebViewController: UIViewController, UIWebViewDelegate {
    
    public var userid:String?
    public var ukey:String?
    
    public var kind:String!
    public var isMenuShow:Bool = true

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var webView: UIWebView!
    
    var urlString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.webView.scrollView.bounces = false
        
        self.menuButton.isHidden = !self.isMenuShow
        
        
        self.titleLabel.text = ""
        
        debugPrint("self.kind = %@", self.kind)
        
        switch self.kind {
            case "healthcare":
                self.titleLabel.text = "헬스케어 서비스"
                self.urlString = "http://shealthcare.ichc.co.kr/member/terms_view.asp"
                break
            case "personalCollect":
                self.titleLabel.text = "개인정보 수집 및 제공동의"
                self.urlString = "http://shealthcare.ichc.co.kr/member/terms_view.asp"
                break
            case "sensitiveCollect":
                self.titleLabel.text = "민감정보 수집 및 제공동의"
                self.urlString = "http://shealthcare.ichc.co.kr/member/terms_view.asp"
                break
            case "personal3":
                self.titleLabel.text = "제3자 개인정보 제공 동의"
                self.urlString = "http://shealthcare.ichc.co.kr/member/terms_view.asp"
                break
            case "sensitive3":
                self.titleLabel.text = "제3자 민감정보 제공 동의"
                self.urlString = "http://shealthcare.ichc.co.kr/member/terms_view.asp"
                break
            case "personal":
                self.titleLabel.text = "개인정보 처리방침"
                self.urlString = "http://shealthcare.ichc.co.kr/member/terms_view.asp"
                break
            case "medical":
                self.titleLabel.text = "진료▪︎검진"
                self.urlString = "http://shealthcare.ichc.co.kr/reserve/reserve.asp"
            case "emergency":
                self.titleLabel.text = "응급포털"
                self.urlString = "http://shealthcare.ichc.co.kr/customer/ec.asp"
            case "call":
                self.titleLabel.text = "헬스케어센터"
                self.urlString = "http://shealthcare.ichc.co.kr/customer/center.asp"
            
            case "reserve_history":
                self.titleLabel.text = "신청내역"
                self.urlString = "http://shealthcare.ichc.co.kr/reserve/reserve_history.asp"
            case "reserve_treatment":
                self.titleLabel.text = "진료▪︎검진"
                self.urlString = "http://shealthcare.ichc.co.kr/reserve/reserve.asp"
            case "reserve_checkup":
                self.titleLabel.text = "진료▪︎검진"
                self.urlString = "http://shealthcare.ichc.co.kr/reserve/reserve.asp"
            case "checkup":
                self.titleLabel.text = "자가건강체크"
                self.urlString = "http://shealthcare.ichc.co.kr/diagnosis/moonjin_list.asp"
            case "dementia": // 치매
                self.titleLabel.text = "자가건강체크"
                self.urlString = "http://shealthcare.ichc.co.kr/diagnosis/dementia_list.asp"
            case "moonjin": // 간단건강테스트
                self.titleLabel.text = "자가건강체크"
                self.urlString = "http://shealthcare.ichc.co.kr/diagnosis/moonjin_list.asp"
            
            
            case "kakao_s-healthcare":
                self.titleLabel.text = "건강 콘텐츠"
                self.urlString = "https://story.kakao.com/ch/s-healthcare"
            
            case "prevention_guide":
                self.titleLabel.text = "예방 가이드"
                self.urlString = "http://shealthcare.ichc.co.kr/contents/prevention_guide.asp"
            
            case "news":
                self.titleLabel.text = "공지사항"
                self.urlString = "http://shealthcare.ichc.co.kr/notice/notice_list.asp"
            
            case "voucher":
                self.titleLabel.text = "쿠폰"
                self.urlString = "http://shealthcare.ichc.co.kr/service/voucher.asp"
            
            case "brain":
                self.titleLabel.text = "뇌 트레이닝"
                self.urlString = "http://shealthcare.ichc.co.kr/customer/center.asp"
            
            case "convalescence":
                self.titleLabel.text = "요양 지원"
                self.urlString = "http://shealthcare.ichc.co.kr/service/convalescence.asp"
            
            case "care":
                self.titleLabel.text = "간병인 지원"
                self.urlString = "http://shealthcare.ichc.co.kr/service/carer.asp"
            
            case "dementia":
                self.titleLabel.text = "치매안심지원"
                self.urlString = "http://shealthcare.ichc.co.kr/service/dementia.asp"
            
            
            
            default:
                self.titleLabel.text = self.kind
                self.urlString = "http://shealthcare.ichc.co.kr/customer/center.asp"
                break
        }
        
        
        MKProgress.show()
        
        let _userid = (self.userid != nil) ? self.userid : Global.userid
        let _ukey = (self.ukey != nil) ? self.ukey : Global.ukey
        
        if let url = URL(string: self.urlString){
            if self.kind == "kakao_s-healthcare" {
                let request = URLRequest(url: url)
                self.webView.loadRequest(request);
            } else {
                let query :[String:String] = ["os":"ISO",
                                              "userid":_userid!,
                                              "ukey":_ukey!,
                                              "kind":self.kind]
                
                var request = try! URLRequest(url: url, method: .post)
                let postString = (url.withQueries(query)!).query
                request.httpBody = postString?.data(using: .utf8)
                self.webView.loadRequest(request);
            }
        }
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {        
        if self.webView.canGoBack {
            self.webView.goBack()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionMenuButton(_ sender: Any) {
        let mypageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageViewController") as! MypageViewController
        self.navigationController?.pushViewController(mypageViewController, animated: true)
    }
    
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        let request:URLRequest! = request
        let strScheme:String? = request.url!.scheme
        let strHost:String? = request.url!.host
        let strQuery:String? = request.url!.query
        let urlString:String! = request.url!.absoluteString
        
        debugPrint("request = %@", request)
        debugPrint("strScheme = %@", strScheme)
        debugPrint("strHost = %@", strHost)
        debugPrint("strQuery = %@", strQuery)
        debugPrint("urlString = %@", urlString)
        
        // 외부 URL
        if let url = request.url,
            let host = url.host {
            if host == "www.e-gen.or.kr" || host == "caredoc.kr" {
                UIApplication.shared.open(url, options: [:]) { (b) in
                    
                }
                return false;
            }
        }
        
        
        if urlString.contains("changhc_callback://") {
            
            let _arr = urlString.components(separatedBy: "changhc_callback://")
            if _arr.count == 2 {
                debugPrint(_arr[_arr.count - 1])
                let _bridgeString = _arr[_arr.count - 1]
                let _func = _bridgeString.components(separatedBy: "?")[0]
                
                if _func == "reserve_history" // 신청내역
                    || _func == "reserve_treatment" // 진료예약
                    || _func == "reserve_checkup" // 검진예약
                {
                    if let _queryDic = request.url!.queryDictionary, _queryDic["ResultCode"] == "0" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                            webViewController.kind = _func
                            self.navigationController?.pushViewController(webViewController, animated: true)
                        }
                    }
                }
                // 측정기록
                else if _func == "cervical_list" {
                    let turtleNeckResultViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckResultViewController") as! TurtleNeckResultViewController
                    self.navigationController?.pushViewController(turtleNeckResultViewController, animated: true)
                }
                // 거북목 측정
                else if _func == "cervical_turtle" {
                    let turtleNeckViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckViewController") as! TurtleNeckViewController
                    self.navigationController?.pushViewController(turtleNeckViewController, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        var viewControllers = self.navigationController?.viewControllers
                        if let _count = viewControllers?.count {
                            viewControllers?.remove(at: _count - 2)
                            self.navigationController?.viewControllers = viewControllers!
                        }
                    }
                }
                // 고개를 들어요
                else if _func == "cervical_head" {
                    let headUpViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "HeadUpViewController") as! HeadUpViewController
                    self.navigationController?.pushViewController(headUpViewController, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        var viewControllers = self.navigationController?.viewControllers
                        if let _count = viewControllers?.count {
                            viewControllers?.remove(at: _count - 2)
                            self.navigationController?.viewControllers = viewControllers!
                        }
                    }
                }
            }
            
            
            return false
        }
        
        
        if navigationType == UIWebView.NavigationType.linkClicked {
            if urlString.range(of: "tel:") != nil {
                if UIApplication.shared.canOpenURL(request.url!) {
                    UIApplication.shared.open(request.url!, options: [:], completionHandler: nil)
                }
                return false
            }
        }
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        MKProgress.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        MKProgress.hide()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        MKProgress.hide()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
