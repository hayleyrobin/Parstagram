//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Hayley Robinson on 3/11/21.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //UIImagePickerControllerDelegate calls function to take image from camera

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        let post = PFObject(className: "Posts")
         //parse read arbitray created dict
        post["caption"] = commentField.text
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image?.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!) //binary object
        
        //this column has url for table of photo
        post["image"] = file
        
        //creates columns for me and saves it
        post.saveInBackground { (success, error) in
            if (success){
                self.dismiss(animated: true, completion: nil) //if successful, dismisses camera view
                print("Saved")}
            else{ print("Error")}
        }
        
        /*
         Creates schema for pets
         
        let pet = PFObject(className: "Pets")
         //parse read arbitray created dict
        pet["name"] = "Spencer"
        pet["weight"] = 50
        pet["owner"] = PFUser.current()
        
        //creates columns for me and saves it
        pet.saveInBackground { (success, error) in
            if (success){ print("Save")}
            else{ print("Error")}
        }
        */
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        // doesnt have custom view of camera
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    // pick image and resize it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
        
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
