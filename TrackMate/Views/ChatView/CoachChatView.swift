//
//  CoachChatView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 10/10/26.
//

import SwiftUI
import CoreData

struct CoachChatView: View {
	@State private var viewModel = CoachChatViewModel()
	@State private var userInput: String = ""
	@Environment(\.managedObjectContext) private var viewContext
	@Environment(\.scenePhase) private var scenePhase
	@EnvironmentObject var themeManager: ThemeManager
	
	var body: some View {
		VStack(spacing: 0) {
				  headerView
				  
				  ScrollViewReader { proxy in
					 ScrollView {
						LazyVStack(spacing: 16) {
						    modelStatusView
							   .padding(.top)
						    
						    ForEach(viewModel.messages) { message in
							   chatBubble(for: message)
								  .id(message.id)
						    }
						}
						.padding()
					 }
					 .onChange(of: viewModel.messages.last?.content) { _, _ in
						if let lastId = viewModel.messages.last?.id {
						    withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
						}
					 }
				  }
				  // Use ThemeManager for the main background
				  .background(Color(themeManager.color("PrimaryBackground")))
				  
				  inputArea
			   }
			   .task {
				  await viewModel.initialize()
			   }
			   .onChange(of: scenePhase) { _, newPhase in
				  if newPhase == .background {
					 viewModel.unload()
				  } else if newPhase == .active {
					 Task { await viewModel.initialize() }
				  }
			   }
		    }
		    
		    // MARK: - Subviews
		    
		    private var headerView: some View {
			   HStack {
				  Image("TrackingMateAvatar")
					 .resizable()
					 .scaledToFit()
					 .frame(width: 40, height: 40)
					 .clipShape(Circle())
				  
				  Text("TrackMate Coach")
					 .font(.headline)
					 .foregroundColor(Color(themeManager.color("PrimaryText")))
				  
				  Spacer()
			   }
			   .padding()
			   .background(Color(themeManager.color("SecondaryBackground")).ignoresSafeArea(edges: .top))
		    }
		    
		    @ViewBuilder
		    private var modelStatusView: some View {
			   switch viewModel.service.state {
			   case .downloading(let progress):
				  VStack(spacing: 8) {
					 ProgressView(value: progress, total: 1.0)
						.progressViewStyle(.linear)
						.tint(Color(themeManager.color("AccentColor")))
					 Text("Downloading Coach AI... \(Int(progress * 100))%")
						.font(.caption)
						.foregroundColor(Color(themeManager.color("SecondaryText")))
				  }
				  .padding()
				  .background(Color(themeManager.color("SecondaryBackground")))
				  .cornerRadius(12)
			   case .failed(let error):
				  Text("Failed to load AI: \(error)")
					 .font(.caption)
					 .foregroundColor(.red)
			   default:
				  EmptyView()
			   }
		    }
		    
		    private func chatBubble(for message: ChatMessage) -> some View {
			   HStack {
				  if message.role == .user { Spacer() }
				  
				  Text(message.content)
					 .padding(12)
					 // User gets the Accent Color, Coach gets the CardFill color
					 .background(message.role == .user ? Color("\(themeManager.assetPrefix)AccentColor") : Color("\(themeManager.assetPrefix)CardFill"))
					 .foregroundColor(message.role == .user ? .white : Color(themeManager.color("PrimaryText")))
					 .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
				  
				  if message.role == .coach { Spacer() }
			   }
		    }
		    
		    private var inputArea: some View {
			   HStack {
				  TextField("Ask for advice...", text: $userInput)
					 .padding(12)
					 .background(Color(themeManager.color("SecondaryBackground")))
					 .cornerRadius(20)
					 .foregroundColor(Color(themeManager.color("PrimaryText")))
					 .disabled(viewModel.service.state != .ready)
				  
				  Button {
					 let textToSend = userInput
					  userInput = ""
					 Task {
						await viewModel.sendMessage(textToSend, viewContext: viewContext)
					 }
				  } label: {
					 Image(systemName: "arrow.up.circle.fill")
						.font(.system(size: 32))
						.foregroundColor(userInput.isEmpty || viewModel.isThinking ? .gray : Color(themeManager.color("AccentColor")))
				  }
				  .disabled(userInput.isEmpty || viewModel.isThinking || viewModel.service.state != .ready)
			   }
			   .padding()
			   .background(Color(themeManager.color("PrimaryBackground")))
		    }
		}
