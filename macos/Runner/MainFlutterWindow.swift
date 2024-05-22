import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    let cursorChannel = FlutterMethodChannel(
      name: "jazzsim.soda/cursor",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    cursorChannel.setMethodCallHandler { (call, result) in
      switch call.method {
        case "cursorInsideWindow":
          guard let inside = isCursorInsideWindow() else {
            result(
              FlutterError(
                code: "UNAVAILABLE",
                message: "Cursor is not inside window",
                details: nil))
          return
          }
          result(inside)
        default:
          result(FlutterMethodNotImplemented)
      }
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

func isCursorInsideWindow() -> Bool? {
  let cursorPoint = NSEvent.mouseLocation
  let windowRect = NSApplication.shared.mainWindow?.frame ?? .zero

  if NSPointInRect(cursorPoint, windowRect) {
    // Cursor is within the app's window
    return true
  }
  return false
}