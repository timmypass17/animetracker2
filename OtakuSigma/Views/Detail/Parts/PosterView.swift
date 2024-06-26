//
//  PosterView.swift
//  OtakuSigma
//
//  Created by Timmy Nguyen on 10/24/23.
//

import SwiftUI

struct PosterView: View {
    @Environment(\.colorScheme) var colorScheme

    let imageURL: String
    let width: CGFloat
    let height: CGFloat
    var includeBorder: Bool = true
    
    var body: some View {
        
        if !includeBorder || colorScheme == .light {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color(uiColor: UIColor.tertiarySystemFill)
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        } else {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.secondary)
                    }
                    .shadow(radius: 2)
            } placeholder: {
                Color(uiColor: UIColor.tertiarySystemFill)
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
    }
}

struct PosterView_Previews: PreviewProvider {
    static var previews: some View {
        PosterView(imageURL: sampleAnimes[0].mainPicture.medium, width: 100, height: 140)
            .frame(width: 85, height: 135)
    }
}

