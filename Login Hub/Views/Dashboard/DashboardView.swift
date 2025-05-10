//
//  DashboardView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 02.05.25.
//

import SwiftUI

struct DashboardView: View {
    let userProfile: SocialUserProfile
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: SocialLoginViewModel
    
    private let cardCornerRadius: CGFloat = 15
    private let cardPadding: CGFloat = 16
    private let iconSize: CGFloat = 24
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.2, blue: 0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    ProfileSectionView(userProfile: userProfile)
                    quickActionsSection
                    academicOverviewSection
                    upcomingEventsSection
                    logoutButton
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.isLoggedIn) { _, isLoggedIn in
            if !isLoggedIn {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                quickActionButton(icon: "book.fill", title: "Courses")
                quickActionButton(icon: "calendar", title: "Schedule")
                quickActionButton(icon: "doc.text.fill", title: "Assignments")
                quickActionButton(icon: "chart.bar.fill", title: "Grades")
            }
        }
        .padding(cardPadding)
        .background(Color.white.opacity(0.1))
        .cornerRadius(cardCornerRadius)
    }
    
    // MARK: - Academic Overview Section
    private var academicOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Academic Overview")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                academicStatCard(title: "GPA", value: "3.8", icon: "star.fill")
                academicStatCard(title: "Credits", value: "45", icon: "graduationcap.fill")
            }
        }
        .padding(cardPadding)
        .background(Color.white.opacity(0.1))
        .cornerRadius(cardCornerRadius)
    }
    
    // MARK: - Upcoming Events Section
    private var upcomingEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Events")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                eventRow(title: "Final Exams", date: "May 15", icon: "calendar")
                eventRow(title: "Project Deadline", date: "May 20", icon: "clock")
                eventRow(title: "Career Fair", date: "May 25", icon: "briefcase")
            }
        }
        .padding(cardPadding)
        .background(Color.white.opacity(0.1))
        .cornerRadius(cardCornerRadius)
    }
    
    // MARK: - Helper Views
    private func quickActionButton(icon: String, title: String) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
    
    private func academicStatCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundColor(.white)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(cardCornerRadius)
    }
    
    private func eventRow(title: String, date: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.white)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Logout Button
    private var logoutButton: some View {
        Button {
            viewModel.logout()
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
                Text("Log Out")
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(cardCornerRadius)
        }
    }
}

// MARK: - ProfileSectionView
/// Displays user avatar and basic info in a styled card.
struct ProfileSectionView: View {
    let userProfile: SocialUserProfile
    private let cardCornerRadius: CGFloat = 15
    private let cardPadding: CGFloat = 16

    var body: some View {
        VStack(spacing: 16) {
            // Profile Image
            Group {
                if let url = URL(string: userProfile.avatarURL ?? "") {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
            }
            
            // User name, email, and provider info
            VStack(spacing: 8) {
                Text(userProfile.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(userProfile.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Signed in with \(userProfile.provider.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding(cardPadding)
        .background(Color.white.opacity(0.1))
        .cornerRadius(cardCornerRadius)
    }
}
