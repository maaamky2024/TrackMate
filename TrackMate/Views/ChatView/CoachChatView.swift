//
//  CoachChatView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 10/10/26.
//

import SwiftUI

struct CoachChatView: View {
	@State private var viewModel = CoachChatViewModel()
	@State private var userInput: String = ""
	@Environment(\.managedObjectContext) var viewContext
	
	var body: some View {
		VStack {
			Image("TrackingMateAvatar")
				.resizable()
				.scaledToFit()
				.frame(width:100, height: 100)
				.clipShape(Circle())
			
			ScrollView {
				Text(viewModel.currentResponse)
					.padding()
			}
			
			HStack {
				TextField("Ask your relationship coach...", text: $userInput)
					.textFieldStyle(.roundedBoarder)
				
				Button("Send") {
					let question = userInput
					userInput = ""
					Task {
						await viewModel.askCoach(question: question, context: viewContext)
					}
				}
				.disabled(viewModel.isthinking || userInput.isEmpty)
			}
			.padding()
		}
		.task {
			await viewModel.loadAI()
		}
	}
}
