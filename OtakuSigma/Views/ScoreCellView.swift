//
//  ScoreCellView.swift
//  OtakuSigma
//
//  Created by Timmy Nguyen on 11/9/23.
//

import SwiftUI

struct ScoreCellView: View {
    let title: String
    let description: String
    var imageString: String? = nil
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title.uppercased())
                .fontWeight(.semibold)
                .padding(.vertical, 2)
                .padding(.horizontal, 5)
                .background(RoundedRectangle(cornerRadius: 2).fill(.blue))
            
            
            HStack(spacing: 0) {
                if let imageString {
                    Image(systemName: imageString)
                }
                
                Text(description)
                    .font(.system(size: 16))
            }
        }
        .font(.caption)
    }
}

struct ScoreCellView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreCellView(title: "Score", description: "8.65", imageString: "star.fill")
    }
}
