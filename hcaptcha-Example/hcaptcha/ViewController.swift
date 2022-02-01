//
//  ViewController.swift
//  hcaptcha
//
//  Created by Baddili Nethaji on 27/11/21.
//
import HCaptcha
import UIKit
import WebKit


class ViewController: UIViewController {
    
    private var endpoint = HCaptcha.Endpoint.default
    private var locale: Locale?
    var hcaptcha = try? HCaptcha( endpoint: HCaptcha.Endpoint.default, locale: Locale.current, size: Size.compact)
    // Size is like compact, normal & visible
    @IBOutlet weak var lblResult: UILabel!
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    private struct Constants {
        static let webViewTag = 123
        static let testLabelTag = 321
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHCaptcha() // https://docs.hcaptcha.com //hcaptcha document
    }
    
    @IBAction func btn_Validate(_ sender: Any) {
        validate()
    }
    func validate() {
        hcaptcha?.validate(on: view) { [weak self] (result: HCaptchaResult) in
            if var passcodeToken = try? result.dematerialize() {
                print(try? result.dematerialize())
//                passcodeToken = "10000000-aaaa-bbbb-cccc-000000000001" // test passcode token
                // to get success true use the test keys available in the document.
                print("passcode: \(passcodeToken)")
                self!.verifyPasscode(passcodeTokenValue: passcodeToken)
                self?.hcaptcha!.stop()
            }
            self?.view.bringSubviewToFront((self?.lblResult)!)
            self?.lblResult.text = try? result.dematerialize()
        }
    }
    
    private func verifyPasscode(passcodeTokenValue: String){
        let testVerifyURL = "https://hcaptcha.com/siteverify?secret=0x0000000000000000000000000000000000000000&response=\(passcodeTokenValue)"
        print("passcode token value: \(passcodeTokenValue)")
        var request = URLRequest(url: URL(string: testVerifyURL)!)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print("json response: \(json)")
                print("success: \(json["success"]) ")
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    
    private func setupHCaptcha() {
        lblResult.tag = Constants.testLabelTag
        lblResult.accessibilityLabel = "webview"
        lblResult.text = "hCaptcha"

        hcaptcha?.configureWebView { webview in
            webview.frame = self.view.bounds
            webview.tag = Constants.webViewTag
            //webview.isHidden = true
        }
    }


}

