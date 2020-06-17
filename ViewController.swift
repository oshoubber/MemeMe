//
//  ViewController.swift
//  MemeMe
//
//  Created by Osama on 6/16/20.
//  Copyright © 2020 Osama. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var shareItem: UIBarButtonItem!
    @IBOutlet weak var cancelItem: UIBarButtonItem!
    @IBOutlet weak var cameraItem: UIBarButtonItem!
    @IBOutlet weak var albumItem: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    
    let toolbarSafeAreaDistance = 79
    
    struct Meme {
        
        var topText: String!
        var bottomText: String!
        var originalImage: UIImage!
        var memedImage: UIImage!
    }
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -3
    ]
    
    var keyboardIsShown = false
    var currentTexfield: UITextField?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextAttributes()
        shareItem.isEnabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        bottomToolbar.isHidden = true

        if !keyboardIsShown && currentTexfield == bottomText {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
            keyboardIsShown = true
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        bottomToolbar.isHidden = false
        self.view.frame.origin.y = 0
        keyboardIsShown = false
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height - CGFloat(toolbarSafeAreaDistance)
    }
    
    func setTextAttributes() {
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = .center
        bottomText.textAlignment = .center
        topText.delegate = self
        bottomText.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentTexfield = textField
    
        if textField.text == "TOP TEXT" || textField.text == "BOTTOM TEXT" {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        currentTexfield = nil
        if textField == topText && textField.text! == "" {
            textField.text = "TOP TEXT"
        }
        if textField == bottomText && textField.text! == "" {
            textField.text = "BOTTOM TEXT"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    // Open image picker
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Open camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func shareItemAction(_ sender: Any) {
        share()
    }
    
    
    // Dismisses imagePicker once image was chosen and sets image view
    func imagePickerController (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage { memeImageView.image = image }
        shareItem.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func hideOrShowControls(flag: Bool) {
        if flag {
            topToolbar.isHidden = true
            bottomToolbar.isHidden = true
        } else {
            topToolbar.isHidden = false
            bottomToolbar.isHidden = false
        }
    }
    
    func generateMemedImage() -> UIImage {
        
        hideOrShowControls(flag: true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideOrShowControls(flag: false)

        return memedImage
    }
    
    func share() {
        let memeToShare = generateMemedImage()
        
        let activity = UIActivityViewController(activityItems: [memeToShare], applicationActivities: nil)
        activity.completionWithItemsHandler = { (activity, success, items, error) in }
        present(activity, animated: true, completion:nil)
    }

}

