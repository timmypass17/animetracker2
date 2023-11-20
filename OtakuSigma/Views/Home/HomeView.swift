//
//  ContentView.swift
//  OtakuSigma
//
//  Created by Timmy Nguyen on 10/22/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ScrollView {
            VStack {
                if homeViewModel.selectedMediaType == .anime {
                    StatusPickerView(selectedStatus: $homeViewModel.selectedAnimeStatus)
                        .padding(.horizontal)
                    WatchListView(items: homeViewModel.userAnimeList)
                } else {
                    StatusPickerView(selectedStatus: $homeViewModel.selectedMangaStatus)
                        .padding(.horizontal)
                    
                    WatchListView(items: homeViewModel.userMangaList)
                }
            }
            .onOpenURL { url in
                Task {
                    await homeViewModel.generateAccessToken(from: url)
                }
            }
            .searchable(text: $homeViewModel.filteredText, prompt: "Filter by title") {
                if homeViewModel.selectedMediaType == .anime {
                    WatchListView(items: homeViewModel.filteredUserAnimeList)
                } else {
                    WatchListView(items: homeViewModel.filteredUserMangaList)
                }
            }
            .onChange(of: homeViewModel.filteredText, perform: { newValue in
                homeViewModel.filterTextValueChanged()
            })
            .navigationTitle("Anime Tracker")
            .onChange(of: homeViewModel.selectedAnimeStatus) { _ in
                Task {
                    await homeViewModel.getUserAnimeList()
                }
            }
            .onChange(of: homeViewModel.selectedMangaStatus) { _ in
                Task {
                    await homeViewModel.getUserMangaList()
                }
            }
            .toolbar {
                Button {
                    homeViewModel.mediaButtonTapped()
                } label: {
                    Image(systemName: homeViewModel.mediaImage)
                }

            }
        }
        .overlay {
            if !homeViewModel.authService.isLoggedIn {
                VStack(alignment: .center) {
                    Text("Log into My Anime List")
                    Text("Go to Profile to authorize MyAnimeList account to use app's full functionality")
                }
                .foregroundColor(.secondary)
                    
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(HomeViewModel(authService: MALAuthService(), mediaService: MALService()))
        }
    }
}