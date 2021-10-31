//
//  ImagePreviewViewController.swift
//  CameraTest2
//
//  Created by Abhiram Annaluru on 12/27/20.
//

import Foundation
import UIKit
import ScreenTime

class ImagePreviewViewController : UIViewController
{
    
    var capturedImage : UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello in preview")
        imageView.image = capturedImage
        
    }
    
    @IBAction func sendPic(_ sender: Any) {
        uploadImage(fileName: "one.jpeg", image: capturedImage!)
    }
    
    
    func uploadImage(fileName: String, image: UIImage) {
        print("Hello in uploadImage")
        let url = URL(string: "http://192.168.1.35:8080/upload")

        // generate boundary string using a unique per-app string
        let boundaryConstant = UUID().uuidString
        let fieldName = "myFile"
        let mimeType = "image/jpeg"
        //let mimeType = "image/png"
        
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        let boundaryStart = "--\(boundaryConstant)\r\n"
        let boundaryEnd = "--\(boundaryConstant)--\r\n"
        let contentDispositionString = "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n"
        let contentTypeString = "Content-Type: \(mimeType)\r\n\r\n"

        let session = URLSession.shared

        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")


        //Prepare the body
        let requestBodyData : NSMutableData = NSMutableData()
        requestBodyData.append(boundaryStart.data(using: .utf8)!)
        requestBodyData.append(contentDispositionString.data(using: .utf8)!)
        requestBodyData.append(contentTypeString.data(using: .utf8)!)
        //requestBodyData.append(image.pngData()!)
        requestBodyData.append(image.jpegData(compressionQuality: 0.0)!)
        requestBodyData.append("\r\n".data(using: .utf8)!)
        requestBodyData.append(boundaryEnd.data(using: .utf8)!)

        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: requestBodyData as Data, completionHandler: { responseData, response, error in
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                if let json = jsonData as? [String: Any] {
                    print(json)
                }
            }
        }).resume()
    }
    /*
    func sendFile(
        urlPath:String,
        fileName:String,
        data:NSData,
        completionHandler: @escaping (URLResponse?, NSData?, NSError?) -> Void){

            var url: NSURL = NSURL(string: urlPath)!
        var request1: NSMutableURLRequest = NSMutableURLRequest(url: url as URL)

        request1.httpMethod = "POST"

            let boundary = generateBoundary()
            let fullData = photoDataToFormData(data,boundary:boundary,fileName:fileName)

            request1.setValue("multipart/form-data; boundary=" + boundary,
                forHTTPHeaderField: "Content-Type")

            // REQUIRED!
            request1.setValue(String(fullData.length), forHTTPHeaderField: "Content-Length")

            request1.HTTPBody = fullData
        request1.httpShouldHandleCookies = false

        let queue:OperationQueue = OperationQueue()

            NSURLConnection.sendAsynchronousRequest(
                request1 as URLRequest,
                queue: queue,
                completionHandler:completionHandler)
    }
 */
    
    // this is a very verbose version of that function
    // you can shorten it, but i left it as-is for clarity
    // and as an example
    func photoDataToFormData(data:NSData,boundary:String,fileName:String) -> NSData {
        let fullData = NSMutableData()

        // 1 - Boundary should start with --
        
        
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(
                            using:                             String.Encoding.utf8,
            allowLossyConversion: false)!)

        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"image\"; filename=\"" + fileName + "\"\r\n"
        NSLog(lineTwo)
        fullData.append(lineTwo.data(
                            using: String.Encoding.utf8,
            allowLossyConversion: false)!)

        // 3
        let lineThree = "Content-Type: image/jpg\r\n\r\n"
        fullData.append(lineThree.data(
                            using:                             String.Encoding.utf8,
            allowLossyConversion: false)!)

        // 4
 
        fullData.append(data as Data)

        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data(
                            using: String.Encoding.utf8,
            allowLossyConversion: false)!)

        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.append(lineSix.data(
                            using: String.Encoding.utf8,
            allowLossyConversion: false)!)

        return fullData
    }
 
}
