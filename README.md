### 프로젝트 구성

Clean Arcitecture + MVVM 아키 텍쳐 구성입니다.

VC → VM → RP → Network & CoreData 단방향 의존성 을 가집니다.

활용 라이브러리 - Alamaofire, RxSwift, Snapkit, Kingfisher

```jsx
├── UserList
│   ├── AppDelegate.swift
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset
│   │   │   └── Contents.json
│   │   └── Contents.json
│   ├── Base.lproj
│   ├── CoreData
│   │   ├── CoreDataError.swift
│   │   └── UserCoreData.swift
│   ├── Entity
│   │   └── User.swift
│   ├── Extension
│   │   └── Extension + Bundle.swift
│   ├── Info.plist
│   ├── Network
│   │   ├── NetworkError.swift
│   │   ├── NetworkManager.swift
│   │   └── UserNetwork.swift
│   ├── Presentation
│   │   ├── UserListViewController.swift
│   │   ├── UserViewController.swift
│   │   ├── UserViewModel.swift
│   │   └── View
│   │       ├── ListCollectionViewCell.swift
│   │       ├── SearchUserTextField.swift
│   │       ├── TabButtonView.swift
│   │       └── UserCollectionViewHeader.swift
│   ├── Repository
│   │   └── UserRepository.swift
│   ├── SceneDelegate.swift
│   ├── Secret.plist
│   └── UserList.xcdatamodeld
│       └── UserList.xcdatamodel
│           └── contents
```

Entity

유저 데이터 구조체인 User 가 있습니다. 

즐겨찾기로 Coredata 에 저장될 User 객체는 FavoriteUser 입니다.

Network 

NetworkManager 제너릭한 타입을 받아 네트워크를 사용할수 있습니다.

네트워크를 구현할때 NetworkManager를 사용하여 URL과 필요한 파라미터를 전달하여 네트워킹을 구현합니다. 

NetworkManager 헤더에는 API 호출을 위한 AccessToken을 담고있고

AccessToken 는 Secret.plist 파일 안에 존재하며 해당 파일은 Git 추적에 무시되어 로컬에만 보유합니다.

```jsx
EX> manager.fetchData(url: url, method: .get, dataType: UserResult.self)
```

CoreData

viewContext를 주입 받아 Coredata의 CRUD 작업을 수행 합니다.

Repository

내부데이터인 CoreData와 외부데이터 Network 에 접근 하여 원하는 데이터를 가져오는 역할입니다.

ViewModel

RP로 부터 데이터를 가져오며 View의 상태를 관리합니다. 

ViewContoller 과의 이벤트 전달은 input output 으로만 관리 됩니다.

VC → VM 전달은 Input

VM → VC 전달은 Output에 모두 정의 되어 사용됩니다.

```jsx
  struct Input {
        public let fetchUserQuery: Observable<String>
        public let favoriteUserQuery: Observable<String>
        public let saveFavorite: Observable<User>
        public let deleteFavorite: Observable<Int>
    }
    struct Output {
        public let fetchUserList: Observable<[(user: User, isFavorite: Bool)]>
        public let favoriteUserList: Observable<[String:[User]]>
    }
```

ViewController

UserListViewController - 유저 리스트를 노출하는 Collection view를 포함합니다. 부모 VC 인 UserViewController 와 상호 작용 하여 리스트 데이터를 전달받고 클릭 이벤트를 전달 합니다.

UserViewController - API, 즐겨찾기 두개의 UserListViewController 를 가지고 있는 Container VC입니다.

ViewModel과 상호작용 하여 Input 이벤트를 전달 하고 Output 데이터를 전달 받아 리스트 데이터를 UserListViewController 에 전달 합니다.

### 속도 개선 작업

유저 리스트중 즐겨찾기 목록에 포함된 유저를 식별하기 위해 Set을 활용했고 시간 복잡도를 줄였습니다.

```jsx
let fetchUserList = Observable.combineLatest(fetchUserList, favoriteUserList).map { fetchUsers, favoriteUsers in
    let userSet = Set(favoriteUsers)
    return fetchUsers.map { user in
        if userSet.contains(user) { 
            return (user: user, isFavorite: true)
        } else {
            return (user: user, isFavorite: false)
        }
        
    }
}
```

Coredata에 즐겨찾기 데이터는 유저 리스트 형태로 들어가지만 ViewController 에서 사용 할떄는 

Dictionary로 전환하여 이니셜 별로 섹션 구현에 용이하도록 사용했습니다. 

Array → Dictionary로 전환하는 방법은 reduce를 활용하여 시간복잡도를 줄였습니다.

```jsx
let groupedUsers = users.reduce(into: [String: [User]]()) { (dict, user) in
    let index = user.name.index(user.name.startIndex, offsetBy: 1)
    let key = String(user.name[..<index])
    dict[key, default: []].append(user)
}

```

### 향후 개선 작업

~~User - favorite 분리 리팩토링~~

~~User 페이지 네이션~~

~~coredata 자동 마이그레이션 세팅~~

~~네트워크 캐싱 세팅~~

~~Network 에러 처리~~

~~coredata 에러 처리~~

로딩 UI 구현

pullToRequest 구현

핵심 로직 Test code 작성
