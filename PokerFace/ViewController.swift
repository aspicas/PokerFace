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
    @IBOutlet weak var blurSlider: UISlider!
    
    var inputImage: UIImage?
    
    var showSquares = true
    var detectedFaces = [(observation: VNFaceObservation, isBlurred: Bool)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.isUserInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toogleSqueare))
        recognizer.numberOfTapsRequired = 2
        self.imageView.addGestureRecognizer(recognizer)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePhoto))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePhoto))
    }
    
    override func viewDidLayoutSubviews() {
        addFaceRects()
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
                self.addFaceRects()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addFaceRects() {
        //Elimina rectangulos anteriores
        self.imageView.subviews.forEach { $0.removeFromSuperview() }
        
        //Define el tamaño de la imagen dentro de la ImageView
        let imageRect = self.imageView.contentClippingRect
        
        for (index, face) in self.detectedFaces.enumerated() {
            //Las fronteras de la cara
            let boundingBox = face.observation.boundingBox
            //Tamaño de la cara
            let size = CGSize(width: boundingBox.width * imageRect.width,
                              height: boundingBox.height * imageRect.height)
            //Posicion de la cara
            var origin = CGPoint(x: boundingBox.midX * imageRect.width, y: (1 - boundingBox.minY) * imageRect.height - size.height)
            
            //Offset
            origin.y += imageRect.minY
            
            //Colocamos la UIView
            let view = UIView(frame: CGRect(origin: origin, size: size))
            view.tag = index
            view.layer.borderColor = UIColor.red.cgColor
            if showSquares {
                view.layer.borderWidth = 2
            } else {
                view.layer.borderWidth = 0
            }
                
            self.imageView.addSubview(view)
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(faceTapped))
            recognizer.numberOfTapsRequired = 1
            view.addGestureRecognizer(recognizer)
        }
    }
    
    func renderBlurredFaces() {
        guard let uiImage = inputImage else { return }
        guard let cgImage = uiImage.cgImage else { return }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(Int(self.blurSlider.value), forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return }
        
        let blurredImage = UIImage(ciImage: outputImage)
        
        let renderer = UIGraphicsImageRenderer(size: uiImage.size)
        
        let result = renderer.image { (ctx) in
            uiImage.draw(at: .zero)
            
            let path = UIBezierPath() //Renderiza UIViews personalizados
            
            for face in detectedFaces {
                if face.isBlurred {
                    let boundingBox = face.observation.boundingBox
                    let size = CGSize(width: boundingBox.size.width * uiImage.size.width,
                                      height: boundingBox.size.height * uiImage.size.height)
                    let origin = CGPoint(x: boundingBox.midX * uiImage.size.width, y: (1-boundingBox.midY) * uiImage.size.height)
                    let rect = CGRect(origin: origin, size: size)
                    path.append(UIBezierPath(rect: rect))
                }
            }
            
            if !path.isEmpty {
                path.addClip()
                blurredImage.draw(at: .zero)
            }
        }
        
        self.imageView.image = result
    }
    
    @objc func faceTapped(_ sender: UITapGestureRecognizer){
        guard let view = sender.view else { return }
        let tag = view.tag
        self.detectedFaces[tag].isBlurred = !self.detectedFaces[tag].isBlurred
        renderBlurredFaces()
    }
    
    @objc func sharePhoto(){
        guard let image = self.imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc func toogleSqueare(){
        showSquares = !showSquares
        detectFaces()
    }
    
    @IBAction func blurChange() {
        self.renderBlurredFaces()
    }
    
}

