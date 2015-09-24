//
//  ViewController.swift
//  Meme
//
//  Created by John David Stroud on 9/20/15.
//  Copyright © 2015 John David Stroud. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,  // should i name the vanilla view controller something else?
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

    // creates the meme.  Initializes the Meme model object
    func save() -> Meme {
        let meme = Meme(topText: topTextButton.text!,
            bottomText: bottomTextButton.text!,
            originalImage: imagePickerView.image!,
            memedImage: generateMemedImage())
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
        //  hides toolbar and navbar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        return memedImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: NSNumber(float: -3.0),
        ]
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // share and cancel button have not been disabled until the image has been selected.  should i do this?
        self.subscribeToKeyboardNotifications() // sign up to be notified when keyboard appears.  do i have to include self right here?
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications() // again, is it necesarry for me to declare self right here?
    }
    
    // when the keyboardWillShow notification is received, shift the view frame up
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification) // does it matter if i turn this into an if/else statement and why?
    } // how would it be different if this was turned into an if/else statement
    
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
    
    // launches the image picker and sets delegate for the album
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func shareAnImage(sender: AnyObject) { // sharing the meme image
        let newMeme = save()
        let memedImage = newMeme.memedImage
        let nextController = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil) // do we need optional right here? - on memedImage
        presentViewController(nextController, animated: true, completion: nil)
    }
    
    @IBAction func cancelAnImage(sender: UIBarButtonItem) {
        topTextButton.text = "Top"
        bottomTextButton.text = "Bottom"
        imagePickerView.image = nil
        shareButton.enabled = false
        cancelButton.enabled = false
}
  
    // retrieves the image from the image picker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            self.dismissViewControllerAnimated(true, completion: nil) // do we need to declare self right here?
        }
    }
}

