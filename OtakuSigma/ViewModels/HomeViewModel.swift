//
//  HomeViewModel.swift
//  OtakuSigma
//
//  Created by Timmy Nguyen on 10/22/23.
//

import Foundation
import UIKit

@MainActor
class HomeViewModel: ObservableObject {
    @Published var userAnimeList: [UserNode<Anime, AnimeListStatus>] = []
    @Published var userMangaList: [UserNode<Manga, MangaListStatus>] = []
    @Published var filteredText = ""
    @Published var selectedMediaType: MediaType = .anime
    @Published var selectedAnimeStatus: AnimeStatus = .watching
    @Published var selectedMangaStatus: MangaStatus = .reading
    
    @Published var filteredUserAnimeList: [UserNode<Anime, AnimeListStatus>] = []
    @Published var filteredUserMangaList: [UserNode<Manga, MangaListStatus>] = []

    let authService: OAuthService
    let mediaService: MediaService
    
    var mediaImage: String {
        selectedMediaType == .anime ? "tv" : "book"
    }
    
    init(authService: OAuthService, mediaService: MediaService) {
        self.authService = authService
        self.mediaService = mediaService
        
        Task {
            guard let tokenLastUpdated = Settings.shared.accessTokenLastUpdated else { return }
            
            print("User has access token")
            // Check if access token expired
            let tokenExpirationDate = tokenLastUpdated.addingTimeInterval(Settings.accessTokenDurationInSeconds)
            let isTokenExpired = tokenExpirationDate < .now
            if isTokenExpired {
                print("Token Expired... refresing access token")
                await authService.refreshAccessToken()
            }
            
            print("Initalizing user data")
            // Initalize user's data
            await getUserAnimeList()
            await getUserMangaList()
        }
    }
    
    func filterTextValueChanged() {
        if selectedMediaType == .anime {
            filteredUserAnimeList = userAnimeList.filter { $0.node.title.lowercased().contains(filteredText.lowercased()) }
        } else {
            filteredUserMangaList = userMangaList.filter { $0.node.title.lowercased().contains(filteredText.lowercased()) }
        }
    }
    
    func getUserAnimeList() async {
        do {
            userAnimeList = try await mediaService.getUserList(status: selectedAnimeStatus.rawValue, sort: AnimeSort.animeTitle.rawValue).data
        } catch {
            print("Error getting user anime list. Check if access token is valid: \(error)")
        }
    }
    
    func getUserMangaList() async {
        do {
            userMangaList = try await mediaService.getUserList(status: selectedMangaStatus.rawValue, sort: MangaSort.mangaTitle.rawValue).data
        } catch {
            print("Error getting user manga list. Check if access token is valid: \(error)")
        }
    }
    
    func authorizeButtonTapped() {
        guard let authorizationURL = authService.buildAuthorizationURL() else { return }
        UIApplication.shared.open(authorizationURL)
    }
    
    func generateAccessToken(from url: URL) async {
        guard let codeVerifier = authService.codeVerifier else { return }
        await authService.generateAccessToken(from: url, codeVerifier: codeVerifier)
    }
    
    func mediaButtonTapped() {
        selectedMediaType = selectedMediaType == .anime ? .manga : .anime
        print(selectedMediaType.rawValue)
    }
}
