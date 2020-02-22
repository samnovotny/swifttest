import Foundation

print("Hello, Swift world!")

DispatchQueue.global(qos: .background).async {
  var i = 0
  while true {
      i += 1
      print("😜\(i)")
      Thread.sleep(forTimeInterval: 1)
  }
}

DispatchQueue.global(qos: .background).async {
  for i in 1...5 {
      print("🤢\(i)")
  }
}

repeat {
    Thread.sleep(forTimeInterval: 1)
} while true
