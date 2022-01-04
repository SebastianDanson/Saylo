//
//  TextArea.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import SwiftUI
import UIKit

fileprivate struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator

        textView.isEditable = true
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor.clear
        textView.textContainer.lineFragmentPadding = 0
//        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        textView.returnKeyType = .default
        
        textView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        textView.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1).cgColor
        textView.layer.borderWidth = 0.9
        textView.layer.cornerRadius = 18
        textView.textContainerInset = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 34)
             
//        let placeholderLabel = UILabel()
//        placeholderLabel.text = "Message..."
//        placeholderLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        placeholderLabel.textColor = .lightGray
//        
//        textView.addSubview(placeholderLabel)
//        placeholderLabel.anchor(left: textView.leftAnchor, paddingLeft: 15)
//        placeholderLabel.centerY(inView: textView)
        
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        if uiView.window != nil, !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = min(newSize.height,150) // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?

        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            withAnimation(.linear(duration: 0.1)) {
                text.wrappedValue = uiView.text
                UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
            }
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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

    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat
    @State private var showingPlaceholder = false

    init (_ placeholder: String = "", text: Binding<String>, height: CGFloat = 100, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self.dynamicHeight = height
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, onDone: onCommit)
            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
            .background(placeholderView.padding(.top, 0).padding(.leading, 10), alignment: .leading)
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder).foregroundColor(.gray)
            }
        }
    }
}


