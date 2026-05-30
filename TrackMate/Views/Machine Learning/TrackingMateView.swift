//
//  TrackingMateView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 5/30/26.
//

import SwiftUI
import UIKit

struct TrackingMateView: UIViewRepresentable {
    var imageName: String
    
    func makeUIView(context: Context) -> UIImageView {
	   let imageView = UIImageView()
	   imageView.backgroundColor = .clear
	   imageView.contentMode = .scaleAspectFit
	   
	   if let animatedImage = UIImage(named: imageName) {
		  imageView.image = animatedImage
	   }
	   
	   return imageView
}
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
	   
    }
}
