//
//  ViewController.swift
//  PokerFace
//
//  Created by David Garcia on 1/8/18.
//  Copyright © 2018 David Garcia. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
                      UIImagePickerControllerDelegate, //Conjunto de Metodos que se deben implementar para mostrar la seleccion de imagenes.
                      UINavigationControllerDelegate //Modificar el comportamiento cuando un viewController se muestra en una pila de navegacion
                      {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    var inputImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePhoto))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func takePhoto(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        self.inputImage = pickedImage
        self.imageView.image = inputImage
        dismiss(animated: true) {
            //Detectar la cara de los usuarios 
        }
    }
}

