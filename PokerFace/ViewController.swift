//
//  ViewController.swift
//  PokerFace
//
//  Created by David Garcia on 1/8/18.
//  Copyright © 2018 David Garcia. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController,
                      UIImagePickerControllerDelegate, //Conjunto de Metodos que se deben implementar para mostrar la seleccion de imagenes.
                      UINavigationControllerDelegate //Modificar el comportamiento cuando un viewController se muestra en una pila de navegacion
                      {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    var inputImage: UIImage?
    
    var detectedFaces = [(observation: VNFaceObservation, isBlurred: Bool)]()
    
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
            self.detectFaces()
        }
    }
    
    func detectFaces() {
        guard let inputImage = inputImage else { return }
        guard let ciImage = CIImage(image: inputImage) else { return }
        
        let request = VNDetectFaceRectanglesRequest { [unowned self]
            request, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let observations = request.results as? [VNFaceObservation] else { return }
                self.detectedFaces = Array(zip(observations, [Bool](repeating: false, count: observations.count)))
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
}

