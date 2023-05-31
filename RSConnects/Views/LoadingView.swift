//
//  LoadingView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/30/23.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 420)
                .ignoresSafeArea()
            LottieView(lottieFile: "Loading")
                .frame(width: 400, height: 400)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
