//
//  CameraMainView.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import SwiftUI

struct CameraMainView: View {

  @State var isRecording = false
    var cameraView = CameraView()
    @StateObject var viewModel: CameraViewModel
    @State var hasFinishedRecording: Bool = false
    
    //init(viewModel: CameraViewModel) {
      //  self.viewModel = viewModel
       // self.cameraView = CameraView(viewModel: viewModel)
  //  }
  
  var body: some View {
    VStack {
      ZStack {
        cameraView
        VStack {
          HStack {
            Spacer()
            Button {
                cameraView.switchCamera()
            } label: {
              Image(systemName: "arrow.triangle.2.circlepath.camera")
                .padding()
                .foregroundColor(.white)
            }
          }
          Spacer()
          HStack {
            Spacer()
            Button {
              if !isRecording {
                cameraView.startRecording()
              } else {
                cameraView.stopRecording()
                
              }
              isRecording.toggle()
            } label: {
              Image(systemName: "record.circle")
                .font(.system(size: 60))
                .foregroundColor(isRecording ? Color.red : Color.white)
            }
//            .background(NavigationLink(destination: VideoPlayerView(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/video.MOV%20(1).mp4?alt=media&token=a70ab00a-5ca7-4bd0-ae76-c16a09e40a3a")!), isActive: $viewModel.hasRecordedVideo) { EmptyView() } .hidden())

            .popover(isPresented: $viewModel.hasRecordedVideo, content: {
                if let url = viewModel.url {
                    VideoPlayerView(url: url)
                }
                //else {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        if let url = cameraView.getVideoUrl() {
//                            VideoPlayerView(url: url)
//                        }
//                    }
              //  }
            })
            Spacer()
          }
        }
      }
    }.environmentObject(viewModel)
  }
}

//struct CameraMainView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraMainView()
//    }
//}
