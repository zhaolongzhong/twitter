# Project 4 - *Twitter*

**Twitter** is a basic twitter app to read and compose tweets from the [Twitter API](https://apps.twitter.com/).

Time spent: **16** hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] Hamburger menu
   - [X] Dragging anywhere in the view should reveal the menu.
   - [X] The menu should include links to your profile, the home timeline, and the mentions view.
   - [X] The menu can look similar to the example or feel free to take liberty with the UI.
- [X] Profile page
   - [X] Contains the user header view
   - [X] Contains a section with the users basic stats: # tweets, # following, # followers
- [X] Home Timeline
   - [X] Tapping on a user image should bring up that user's profile page

The following **optional** features are implemented:

- [ ] Profile Page
   - [ ] Implement the paging view for the user description.
   - [X] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
   - [X] Pulling down the profile page should blur and resize the header image.
- [ ] Account switching
   - [ ] Long press on tab bar to bring up Account view with animation
   - [ ] Tap account to switch to
   - [ ] Include a plus button to Add an Account
   - [ ] Swipe to delete an account

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Profile page implementation
2. Hamburger navigation

## Libraries and tools used
- [OAuthSwift](https://github.com/OAuthSwift/OAuthSwift) - Swift based OAuth library for iOS
- [Kingfisher](https://github.com/onevcat/Kingfisher) - A lightweight, pure-Swift library for downloading and caching images from the web.

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<!-- ![Video Walkthrough](twitter.gif) -->
![Video Walkthrough](twitter2.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## License

    Copyright 2016 Zhaolong Zhong

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.