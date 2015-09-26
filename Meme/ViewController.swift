//
//  ViewController.swift
//  Meme
//
//  Created by John David Stroud on 9/20/15.
//  Copyright © 2015 John David Stroud. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextButton: UITextField!
    @IBOutlet weak var bottomTextButton: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var meme:UIImage!

    // creates the meme.  Initializes the Meme model object.  Created and works with struct file.
    func save() -> Meme {
        let meme = Meme(topText: topTextButton.text!, bottomText: bottomTextButton.text, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        return meme
    }
    
    //  method to generate the meme while hiding and unhiding the tool bars
    // combines the original image with overlayed text
    func generateMemedImage() -> UIImage
    {
        // hides toolbar and navbar
        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
        // renders view to image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //  shows toolbar and navbar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        return memedImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set font style and color with textAttributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: NSNumber(float: -3.0),
        ]
        
        // Setting the defaultTextAttributes
        setupTextField(topTextButton, text: " TOP ", delegate: self, attributes:    
            memeTextAttributes, alignment: NSTextAlignment.Center)
        setupTextField(bottomTextButton, text: "BOTTOM ", delegate: self, attributes:
            memeTextAttributes, alignment: NSTextAlignment.Center)
    }
    
    func setupTextField (textField: UITextField, text: String, delegate: UITextFieldDelegate,
        attributes: [String : NSObject], alignment: NSTextAlignment) {
        textField.text = text
        textField.delegate = delegate
        textField.defaultTextAttributes = attributes
        textField.textAlignment = alignment
    }
    
    var memes: [Meme]!
    // Sign up to be notified when the keyboard appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        self.subscribeToKeyboardNotifications()
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Unsubscribe from keyboard notifications
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // when the keyboardWillShow notification is received, shift the view frame up
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // declare function to sign up to be notified when the keyboard appears
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // declare function to sign up to be notified when the keyboard disappears
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Launch the image picker and set the UIImagePickerControllerDelegate:
    @IBAction func pickAnImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // Specifying sourceType
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // Specifying sourceType
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func shareAnImage(sender: AnyObject) {
        let newMeme = save()
        let memedImage = newMeme.memedImage
        let nextController = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        presentViewController(nextController, animated: true, completion: nil)
    }
    
    @IBAction func cancelAnImage(sender: UIBarButtonItem) {
        topTextButton.text = "Top"
        bottomTextButton.text = "Bottom"
        imagePickerView.image = nil
        shareButton.enabled = false
        cancelButton.enabled = false
    }
  
    // Retrieve the image from the image picker.  Receive the image from the delegate pattern
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(imagePicker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

