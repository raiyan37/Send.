import Foundation

// Hard-coded preview/sample data to use while backend is not ready.
// These types are defined in APIResponseManager.swift.

var previewFeedData: FeedResponseBody = FeedResponseBody(posts: [
    .init(
        id: "post1",
        user: .init(id: "user1", firstName: "John", lastName: "Doe", photoURL: nil),
        climb: .init(routeName: "Overhang Traverse", grade: .v4, status: .completed, gymName: "Local Gym"),
        caption: "Great session at the gym!",
        videoURL: nil,
        thumbnailURL: nil,
        likes: 42,
        comments: 3,
        isLiked: false,
        createdAt: Date()
    )
])

var previewProfileData: ProfileResponseBody = ProfileResponseBody(
    user: .init(
        id: "user1",
        firstName: "John",
        lastName: "Doe",
        email: "john@example.com",
        photoURL: nil,
        memberSince: Date().addingTimeInterval(-86400 * 300),
        maxGrade: .v6
    ),
    stats: .init(
        totalClimbs: 142,
        successRate: 0.73,
        currentGrade: .v4,
        totalSessions: 28,
        followers: 245,
        following: 180
    ),
    sendPyramid: [
        .init(grade: .v2, count: 35),
        .init(grade: .v3, count: 23),
        .init(grade: .v4, count: 12),
        .init(grade: .v5, count: 5),
        .init(grade: .v6, count: 2)
    ],
    stylePreferences: [
        .init(style: .technical, percentage: 85),
        .init(style: .power, percentage: 60),
        .init(style: .endurance, percentage: 70),
        .init(style: .dynamic, percentage: 45)
    ],
    recentActivity: [
        .init(id: "a1", routeName: "Crimpy Slab", grade: .v3, status: .completed, date: Date().addingTimeInterval(-86400), gymName: "Local Gym"),
        .init(id: "a2", routeName: "Dyno Party", grade: .v4, status: .attempted, date: Date().addingTimeInterval(-86400 * 2), gymName: "Local Gym")
    ]
)

var previewProgressData: ProgressResponseBody = ProgressResponseBody(
    progressData: [
        .init(id: "p1", date: Date().addingTimeInterval(-86400 * 30), grade: .v3, count: 10),
        .init(id: "p2", date: Date().addingTimeInterval(-86400 * 15), grade: .v4, count: 8),
        .init(id: "p3", date: Date(), grade: .v4, count: 12)
    ],
    sessions: [
        .init(id: "s1", date: Date().addingTimeInterval(-86400 * 3), duration: 135, climbCount: 12, maxGrade: .v4, gymName: "Local Gym"),
        .init(id: "s2", date: Date().addingTimeInterval(-86400 * 6), duration: 120, climbCount: 10, maxGrade: .v3, gymName: "Local Gym")
    ],
    weaknesses: [
        .init(type: "Overhangs", strengthScore: 0.3),
        .init(type: "Crimps", strengthScore: 0.5),
        .init(type: "Slopers", strengthScore: 0.7)
    ],
    trainingSuggestions: [
        .init(id: "t1", title: "Improve Overhang Technique", description: "Focus on hip positioning", priority: "High"),
        .init(id: "t2", title: "Increase Finger Strength", description: "Add hangboard", priority: "Medium")
    ],
    injuries: [
        .init(id: "i1", bodyPart: "Left Finger A2", status: "Recovering", reportedDate: Date().addingTimeInterval(-86400 * 14), notes: nil)
    ]
)

var previewRouteAnalysisData: RouteAnalysisResponseBody = RouteAnalysisResponseBody(
    routeId: "route1",
    analysisStatus: .completed,
    imageURL: "https://example.com/route.jpg",
    predictedGrade: .v4,
    holds: [
        .init(id: "h1", x: 0.2, y: 0.8, width: 0.1, height: 0.1, type: "jug", confidence: 0.9),
        .init(id: "h2", x: 0.5, y: 0.5, width: 0.1, height: 0.1, type: "crimp", confidence: 0.8)
    ],
    betaOptions: [
        .init(id: "b1", number: 1, difficulty: "Easy", description: "Use left crimp then right jug", routePath: [
            .init(x: 0.5, y: 0.9),
            .init(x: 0.5, y: 0.5)
        ]),
        .init(id: "b2", number: 2, difficulty: "Medium", description: "Dynamic move to sloper", routePath: [
            .init(x: 0.2, y: 0.8),
            .init(x: 0.4, y: 0.4)
        ])
    ]
)

var previewClimbAnalysisData: ClimbAnalysisResponseBody = ClimbAnalysisResponseBody(
    climbId: "climb1",
    analysisStatus: .completed,
    videoURL: "https://example.com/video.mp4",
    duration: 95,
    sections: [
        .init(id: "sec1", name: "Start", startTime: 0, endTime: 20, poseData: nil),
        .init(id: "sec2", name: "Crux", startTime: 20, endTime: 60, poseData: nil),
        .init(id: "sec3", name: "Finish", startTime: 60, endTime: 95, poseData: nil)
    ],
    techniqueScores: [
        .init(category: "Hip Position", score: 85),
        .init(category: "Arm Extension", score: 72)
    ],
    corrections: [
        .init(id: "c1", title: "Keep hips closer", description: "Keep hips closer to wall", severity: "minor", timestamp: 35),
        .init(id: "c2", title: "Extend arms fully", description: "Extend arms before moving", severity: "major", timestamp: 50)
    ],
    comparisonData: .init(
        yourMoves: 12,
        optimalMoves: 10,
        efficiencyScore: 0.82,
        previousAttempts: [
            .init(id: "a1", attemptNumber: 1, score: 70, date: Date().addingTimeInterval(-86400 * 3)),
            .init(id: "a2", attemptNumber: 2, score: 78, date: Date().addingTimeInterval(-86400))
        ]
    )
)
