//
//  TextArea.swift
//  Saylo
//
//  Created by Student on 2021-09-24.
//
import SwiftUI
import UIKit

fileprivate struct UITextViewWrapper: UIViewRepresentable {
    
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var color: Color
    @Binding var calculatedHeight: CGFloat
    var fontSize: CGFloat
    var returnKey: UIReturnKeyType
        
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        
        let textView = UITextView()

        textView.delegate = context.coordinator

        textView.isEditable = true
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.font = UIFont.rounded(ofSize: fontSize, weight: .medium)
        
        textView.textColor = TextOverlayViewModel.shared.fontColor
        textView.becomeFirstResponder()
        textView.returnKeyType = returnKey
        
    
//        textView.layer.borderColor = UIColor.borderGray.cgColor
//        textView.layer.borderWidth = 0.9
//        textView.layer.cornerRadius = 18
//        textView.textContainerInset = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 34)
             
//        let placeholderLabel = UILabel()
//        placeholderLabel.text = "Message..."
//        placeholderLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        placeholderLabel.textColor = .lightGray
//
//        textView.addSubview(placeholderLabel)
//        placeholderLabel.anchor(left: textView.leftAnchor, paddingLeft: 15)
//        placeholderLabel.centerY(inView: textView)
        
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.centerVertically()
        return textView
    }


    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        
        if uiView.text != self.text {
            uiView.text = self.text
        }
        if uiView.window != nil, !uiView.isFirstResponder, returnKey == .send {
            uiView.becomeFirstResponder()
        }
        
        if returnKey == .done {
            uiView.textColor = TextOverlayViewModel.shared.fontColor
        }
        
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
        uiView.centerVertically()
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = min(newSize.height, SCREEN_WIDTH * 1.5) // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, returnKey: returnKey, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var returnKey: UIReturnKeyType
        var onDone: (() -> Void)?

        init(text: Binding<String>, height: Binding<CGFloat>, returnKey: UIReturnKeyType, onDone: (() -> Void)? = nil) {
            self.text = text
            self.returnKey = returnKey
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            withAnimation(.linear(duration: 0.1)) {
                text.wrappedValue = uiView.text
                UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.centerVertically()
            
            if returnKey == .done {
                withAnimation {
                    MainViewModel.shared.showCaption = true
                }
            }
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                
                if returnKey == .send {
                MainViewModel.shared.selectedView = .Video

                if !self.text.wrappedValue.isEmpty {
                    ConversationViewModel.shared.sendMessage(text: self.text.wrappedValue, type: .Text)
                }
                
                self.text.wrappedValue = ""
                } else {
                    textView.resignFirstResponder()
                }
                return false
            }
            
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

            if updatedText.count > (IS_SMALL_WIDTH ? 240 : 300) {
                return false
            }
            
//            if let onDone = self.onDone, text == "\n" {
//                textView.resignFirstResponder()
//                onDone()
//                return false
//            }
            return true
        }
        
    }

}

struct MultilineTextField: View {

    private var placeholder: String
    private var onCommit: (() -> Void)?

    @State private var dynamicHeight: CGFloat
    @State private var showingPlaceholder = false
    @Binding private var text: String
    @Binding private var color: Color

    private var fontSize: CGFloat
    private var returnKey: UIReturnKeyType

    init (_ placeholder: String = "", text: Binding<String>, height: CGFloat = 100, color: Binding<Color> = .constant(.white), fontSize: CGFloat, returnKey: UIReturnKeyType, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self._dynamicHeight = State(initialValue: height)
        self.fontSize = fontSize
        self.returnKey = returnKey
        self._text = text
        self._color = color
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    
    var body: some View {
        
        let textviewwrapper = UITextViewWrapper(text: $text,
                                                color: $color,
                                                calculatedHeight: $dynamicHeight,
                                                fontSize: fontSize,
                                                returnKey: returnKey,
                                                onDone: onCommit)

        textviewwrapper
            .frame(height: self.returnKey == .send ? SCREEN_WIDTH * 1.5:dynamicHeight)
    
    }
}


struct TextView: UIViewRepresentable {
    
    typealias UIViewType = UITextView

    let text: String
    let isFromCurrentUser: Bool

    func makeUIView(context: UIViewRepresentableContext<TextView>) -> UITextView {
        
        let textView = UITextView()

        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isSelectable = false
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .all
        textView.text = text
        textView.textColor = isFromCurrentUser ? .white : .systemBlack
        textView.backgroundColor = .clear
        textView.setWidth(width: SCREEN_WIDTH - 100)
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<TextView>) {
   
    }
}

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
