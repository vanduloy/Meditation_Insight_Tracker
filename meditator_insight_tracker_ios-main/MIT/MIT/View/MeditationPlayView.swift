//import SwiftUI
//import WebKit
//
//struct MeditationPlayView: View {
//    let duration: Int
//    let userId: String
//    @State private var isPlaying = false
//    @State private var elapsedTime: Int = 0
//    @State private var navigateToECGView = false
//    @State private var isFinishButtonActive = false
//    @State private var showFinishReminder = false
//    @State private var isPreMeditation = false
//    @State private var selectedVideo: Int = 1
//    @Environment(\.presentationMode) var presentationMode
//
//    let videos10Min = [
//        "LbNkVq2x5Pg",
//        "UZOoqR-pmUA",
//        "iMSXDvIaaTs"
//    ]
//    
//    let videos20Min = [
//        "nlyHfia8N5k",
//        "n_uxnYz2MHg",
//        "emRxZEeVWOE"
//    ]
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
//                               startPoint: .topLeading,
//                               endPoint: .bottomTrailing)
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack(spacing: 20) {
//                    titleSection
//                    videoSelectionSection
//                    Spacer()
//                    youtubePlayerView
//                    timerSection
//                    Spacer()
//                    finishedButton
//                }
//                .padding(.horizontal)
//                .frame(width: geometry.size.width)
//            }
//            .overlay(finishReminderOverlay)
//        }
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: backButton)
//        .onAppear {
//            resetState()
//        }
//    }
//    
//    private var titleSection: some View {
//        Text("\(duration)-Minute Meditation")
//            .font(.system(size: 28, weight: .bold, design: .rounded))
//            .foregroundColor(.blue)
//            .padding(.top, 50)
//    }
//    
//    private var videoSelectionSection: some View {
//        HStack {
//            ForEach(1...3, id: \.self) { index in
//                Button(action: {
//                    selectedVideo = index
//                    isPlaying = false
//                    elapsedTime = 0
//                }) {
//                    Text("Video \(index)")
//                        .font(.system(size: 16, weight: .medium, design: .rounded))
//                        .foregroundColor(selectedVideo == index ? .white : .blue)
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 12)
//                        .background(selectedVideo == index ? Color.blue : Color.clear)
//                        .cornerRadius(8)
//                }
//            }
//        }
//        .padding(.vertical)
//    }
//    
//    private var youtubePlayerView: some View {
//        YouTubePlayerView(videoID: currentVideoID, isPlaying: $isPlaying)
//            .frame(height: 200)
//            .cornerRadius(15)
//            .onChange(of: isPlaying) { newValue in
//                if newValue {
//                    startTimer()
//                    showFinishReminderOverlay()
//                } else {
//                    stopTimer()
//                }
//            }
//    }
//    
//    private var timerSection: some View {
//        Text("Elapsed Time: \(formattedElapsedTime())")
//            .font(.system(size: 18, weight: .medium, design: .rounded))
//            .foregroundColor(.gray)
//            .padding(.top)
//    }
//    
//    private var finishedButton: some View {
//        Button(action: {
//            if isFinishButtonActive {
//                isPreMeditation = false
//                navigateToECGView = true
//            }
//        }) {
//            Text("Finished")
//                .font(.system(size: 18, weight: .semibold, design: .rounded))
//                .foregroundColor(.white)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(isFinishButtonActive ? Color.blue : Color.gray)
//                .cornerRadius(15)
//        }
//        .disabled(!isFinishButtonActive)
//        .padding(.bottom, 30)
//    }
//    
//    private var finishReminderOverlay: some View {
//        Group {
//            if showFinishReminder {
//                Text("You can now finish your meditation")
//                    .font(.system(size: 18, weight: .medium, design: .rounded))
//                    .padding()
//                    .background(Color.green.opacity(0.8))
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                    .transition(.move(edge: .top))
//                    .animation(.easeInOut, value: showFinishReminder)
//            }
//        }
//    }
//    
//    private var backButton: some View {
//        Button(action: { presentationMode.wrappedValue.dismiss() }) {
//            Image(systemName: "chevron.left")
//                .foregroundColor(.blue)
//                .imageScale(.large)
//        }
//    }
//
//    private func startTimer() {
//        elapsedTime = 0
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            if self.isPlaying {
//                self.elapsedTime += 1
//            } else {
//                timer.invalidate()
//            }
//        }
//    }
//
//    private func stopTimer() {
//        // 停止计时器
//    }
//
//    private func formattedElapsedTime() -> String {
//        let minutes = elapsedTime / 60
//        let seconds = elapsedTime % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//    
//    private var currentVideoID: String {
//        let videos = duration == 10 ? videos10Min : videos20Min
//        return videos[selectedVideo - 1]
//    }
//
//    private func showFinishReminderOverlay() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            isFinishButtonActive = true
//            withAnimation {
//                showFinishReminder = true
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                withAnimation {
//                    showFinishReminder = false
//                }
//            }
//        }
//    }
//
//    private func resetState() {
//        elapsedTime = 0
//        isPlaying = false
//        isFinishButtonActive = false
//        showFinishReminder = false
//    }
//}
//
//struct YouTubePlayerView: UIViewRepresentable {
//    let videoID: String
//    @Binding var isPlaying: Bool
//
//    func makeUIView(context: Context) -> WKWebView {
//        let configuration = WKWebViewConfiguration()
//        configuration.allowsInlineMediaPlayback = true
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0&modestbranding=1&controls=1") else {
//            return
//        }
//        uiView.load(URLRequest(url: youtubeURL))
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
//        var parent: YouTubePlayerView
//
//        init(_ parent: YouTubePlayerView) {
//            self.parent = parent
//        }
//
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            if message.name == "playerStateChanged", let state = message.body as? String {
//                DispatchQueue.main.async {
//                    if state == "playing" {
//                        self.parent.isPlaying = true
//                    } else if state == "paused" {
//                        self.parent.isPlaying = false
//                    }
//                }
//            }
//        }
//
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            let script = """
//            var player;
//            function onYouTubeIframeAPIReady() {
//                player = new YT.Player('player', {
//                    events: {
//                        'onStateChange': onPlayerStateChange
//                    }
//                });
//            }
//            function onPlayerStateChange(event) {
//                if (event.data == YT.PlayerState.PLAYING) {
//                    window.webkit.messageHandlers.playerStateChanged.postMessage('playing');
//                } else if (event.data == YT.PlayerState.PAUSED) {
//                    window.webkit.messageHandlers.playerStateChanged.postMessage('paused');
//                }
//            }
//            """
//            webView.evaluateJavaScript(script, completionHandler: nil)
//        }
//    }
//}
//
//struct MeditationPlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        MeditationPlayView(duration: 10, userId: "1")
//    }
//}
//
//

//import SwiftUI
//import AVKit
//
//struct MeditationPlayView: View {
//    let duration: Int
//    let userId: String
//    @State private var player: AVPlayer?
//    @State private var isPlaying = false
//    @State private var elapsedTime: Int = 0
//    @State private var isFinishButtonActive = false
//    @State private var showFinishReminder = false
//    @State private var selectedVideo: Int = 1
//    @State private var isFullScreen = false
//    @Environment(\.presentationMode) var presentationMode
//    @State private var timer: Timer?
//
//    let videos10Min = [
//        "video1_10min",
//        "video2_10min",
//        "video3_10min"
//    ]
//    
//    let videos20Min = [
//        "video1_20min",
//        "video2_20min",
//        "video3_20min"
//    ]
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
//                               startPoint: .topLeading,
//                               endPoint: .bottomTrailing)
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack(spacing: 20) {
//                    // 仅当不是全屏时显示标题和视频选择
//                    if !isFullScreen {
//                        titleSection
//                        videoSelectionSection
//                    }
////                    Spacer()
//                    ZStack {
//                        videoPlayerView
//                        if !isPlaying && !isFullScreen {
//                            playButton
//                        }
//                    }
//                    // 仅当不是全屏时显示缩放按钮、计时器和完成按钮
//                    if !isFullScreen {
//                        zoomButtonBelowVideoSelection
//                        timerSection
//                        Spacer()
//                        finishedButton
//                    }
//                }
//                .padding(.horizontal)
//                .frame(width: geometry.size.width)
//            }
//            .overlay(finishReminderOverlay)
//        }
//        .navigationBarBackButtonHidden(true)
//        .onAppear {
//            setupPlayer()
//        }
//        .onDisappear {
//            stopTimer()
//            player?.pause()
//        }
//    }
//    
//    private var titleSection: some View {
//        Text("\(duration)-Minute Meditation")
//            .font(.system(size: 28, weight: .bold, design: .rounded))
//            .foregroundColor(.blue)
//            .padding(.top, 50)
//    }
//    
//    private var videoSelectionSection: some View {
//        HStack {
//            ForEach(1...3, id: \.self) { index in
//                Button(action: {
//                    selectedVideo = index
//                    setupPlayer()
//                }) {
//                    Text("Video \(index)")
//                        .font(.system(size: 16, weight: .medium, design: .rounded))
//                        .foregroundColor(selectedVideo == index ? .white : .blue)
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 12)
//                        .background(selectedVideo == index ? Color.blue : Color.clear)
//                        .cornerRadius(8)
//                }
//            }
//        }
//        .padding(.vertical)
//    }
//    
//    private var videoPlayerView: some View {
//        VideoPlayerView(player: player)
//            .aspectRatio(16/9, contentMode: .fit)
//            .frame(height: isFullScreen ? UIScreen.main.bounds.height : 200)
//            .cornerRadius(isFullScreen ? 0 : 15)
//            .onTapGesture {
//                if isFullScreen {
//                    withAnimation {
//                        isFullScreen = false
//                        exitFullScreen()
//                    }
//                }
//            }
//    }
//    
//    private var playButton: some View {
//        Button(action: {
//            startPlaying()
//        }) {
//            Image(systemName: "play.circle.fill")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 50, height: 50)
//                .foregroundColor(.white)
//        }
//    }
//    
//    private var zoomButtonBelowVideoSelection: some View {
//        HStack {
//            Spacer()
//            Button(action: {
//                withAnimation {
//                    isFullScreen.toggle()
//                    if isFullScreen {
//                        enterFullScreen()
//                    }
//                }
//            }) {
//                Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.black.opacity(0.6))
//                    .clipShape(Circle())
//            }
//            .padding(.top)
//        }
//    }
//    
//    private var timerSection: some View {
//        Text("Elapsed Time: \(formattedElapsedTime())")
//            .font(.system(size: 18, weight: .medium, design: .rounded))
//            .foregroundColor(.gray)
//            .padding(.top)
//    }
//    
//    private var finishedButton: some View {
//        Button(action: {
//            if isFinishButtonActive {
//                presentationMode.wrappedValue.dismiss()
//            }
//        }) {
//            Text("Finished")
//                .font(.system(size: 18, weight: .semibold, design: .rounded))
//                .foregroundColor(.white)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(isFinishButtonActive ? Color.blue : Color.gray)
//                .cornerRadius(15)
//        }
//        .disabled(!isFinishButtonActive)
//        .padding(.bottom, 30)
//    }
//    
//    private var finishReminderOverlay: some View {
//        Group {
//            if showFinishReminder {
//                Text("You can now finish your meditation")
//                    .font(.system(size: 18, weight: .medium, design: .rounded))
//                    .padding()
//                    .background(Color.green.opacity(0.8))
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                    .transition(.move(edge: .top))
//                    .animation(.easeInOut, value: showFinishReminder)
//            }
//        }
//    }
//
//    private func setupPlayer() {
//        let videos = duration == 10 ? videos10Min : videos20Min
//        let videoName = videos[selectedVideo - 1]
//        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
//            print("Video file not found")
//            return
//        }
//        let url = URL(fileURLWithPath: path)
//        player = AVPlayer(url: url)
//        
//        // Reset state
//        isPlaying = false
//        elapsedTime = 0
//        isFinishButtonActive = false
//        showFinishReminder = false
//        stopTimer()
//    }
//
//    private func startPlaying() {
//        player?.play()
//        isPlaying = true
//        startTimer()
//        
//        // 自动进入全屏模式
//        withAnimation {
//            isFullScreen = true
//            enterFullScreen()
//        }
//    }
//
//    private func startTimer() {
//        print("Timer started")
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            self.elapsedTime += 1
//            print("Elapsed time: \(self.elapsedTime)")
//            if self.elapsedTime == 5 {
//                self.isFinishButtonActive = true
//                self.showFinishReminder = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    self.showFinishReminder = false
//                }
//            }
//        }
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//
//    private func formattedElapsedTime() -> String {
//        let minutes = elapsedTime / 60
//        let seconds = elapsedTime % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//
//    // 进入全屏并横屏显示
//    private func enterFullScreen() {
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscape)
//            windowScene.requestGeometryUpdate(geometryPreferences) { error in
//                print("Error entering full screen: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    // 退出全屏
//    private func exitFullScreen() {
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
//            windowScene.requestGeometryUpdate(geometryPreferences) { error in
//                print("Error exiting full screen: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//struct VideoPlayerView: UIViewControllerRepresentable {
//    let player: AVPlayer?
//
//    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        let controller = AVPlayerViewController()
//        controller.player = player
//        controller.showsPlaybackControls = false
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//        uiViewController.player = player
//    }
//}


import SwiftUI
import AVKit

struct MeditationPlayView: View {
    let duration: Int
    let userId: String
    var onCompletion: () -> Void // 新增回调
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var elapsedTime: Int = 0
    @State private var isFinishButtonActive = false
    @State private var showFinishReminder = false
    @State private var selectedVideo: Int = 1
    @State private var isFullScreen = false
    @Environment(\.presentationMode) var presentationMode
    @State private var timer: Timer?

    let videos10Min = [
        "video1_10min",
        "video2_10min",
        "video3_10min"
    ]
    
    let videos20Min = [
        "video1_20min",
        "video2_20min",
        "video3_20min"
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    if !isFullScreen {
                        titleSection
                        videoSelectionSection
                    }
                    Spacer()
                    ZStack {
                        videoPlayerView
                        if !isPlaying && !isFullScreen {
                            playButton
                        }
                    }
                    if !isFullScreen {
                        zoomButtonBelowVideoSelection
                        timerSection
                        Spacer()
                        finishedButton
                    }
                }
                .padding(.horizontal)
                .frame(width: geometry.size.width)
            }
            .overlay(finishReminderOverlay)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            stopTimer()
            player?.pause()
        }
    }
    
    private var titleSection: some View {
        Text("\(duration)-Minute Meditation")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(.blue)
            .padding(.top, 50)
    }
    
    private var videoSelectionSection: some View {
        HStack {
            ForEach(1...3, id: \.self) { index in
                Button(action: {
                    selectedVideo = index
                    setupPlayer()
                }) {
                    Text("Video \(index)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(selectedVideo == index ? .white : .blue)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(selectedVideo == index ? Color.blue : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical)
    }
    
    private var videoPlayerView: some View {
        VideoPlayerView(player: player)
            .aspectRatio(16/9, contentMode: .fit)
            .frame(height: isFullScreen ? UIScreen.main.bounds.height : 200)
            .cornerRadius(isFullScreen ? 0 : 15)
            .onTapGesture {
                if isFullScreen {
                    withAnimation {
                        isFullScreen = false
                        exitFullScreen()
                    }
                }
            }
    }
    
    private var playButton: some View {
        Button(action: {
            startPlaying()
        }) {
            Image(systemName: "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
        }
    }
    
    private var zoomButtonBelowVideoSelection: some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation {
                    isFullScreen.toggle()
                    if isFullScreen {
                        enterFullScreen()
                    }
                }
            }) {
                Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(.top)
        }
    }
    
    private var timerSection: some View {
        Text("Elapsed Time: \(formattedElapsedTime())")
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundColor(.gray)
            .padding(.top)
    }
    
    private var finishedButton: some View {
        Button(action: {
            if isFinishButtonActive {
                // 调用完成回调并返回
                onCompletion()
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            Text("Finished")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isFinishButtonActive ? Color.blue : Color.gray)
                .cornerRadius(15)
        }
        .disabled(!isFinishButtonActive)
        .padding(.bottom, 30)
    }
    
    private var finishReminderOverlay: some View {
        Group {
            if showFinishReminder {
                Text("You can now finish your meditation")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.move(edge: .top))
                    .animation(.easeInOut, value: showFinishReminder)
            }
        }
    }

    private func setupPlayer() {
        let videos = duration == 10 ? videos10Min : videos20Min
        let videoName = videos[selectedVideo - 1]
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            print("Video file not found")
            return
        }
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        
        // Reset state
        isPlaying = false
        elapsedTime = 0
        isFinishButtonActive = false
        showFinishReminder = false
        stopTimer()
    }

    private func startPlaying() {
        player?.play()
        isPlaying = true
        startTimer()
        
        // 自动进入全屏模式
        withAnimation {
            isFullScreen = true
            enterFullScreen()
        }
    }

    private func startTimer() {
        print("Timer started")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
            print("Elapsed time: \(self.elapsedTime)")
            if self.elapsedTime == 5 {
                self.isFinishButtonActive = true
                self.showFinishReminder = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showFinishReminder = false
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func formattedElapsedTime() -> String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // 进入全屏并横屏显示
    private func enterFullScreen() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscape)
            windowScene.requestGeometryUpdate(geometryPreferences) { error in
                print("Error entering full screen: \(error.localizedDescription)")
            }
        }
    }

    // 退出全屏
    private func exitFullScreen() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
            windowScene.requestGeometryUpdate(geometryPreferences) { error in
                print("Error exiting full screen: \(error.localizedDescription)")
            }
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
