//
//  ViewController.swift
//  Trivia
//
//  Created by Cyberlord on 3/12/25.
//

import UIKit

// Question model to store question data
struct Question {
    let category: String
    let text: String
    let answers: [(text: String, isCorrect: Bool)]
}

class ViewController: UIViewController {

    private var currentQuestionIndex = 0
    private var correctAnswers = 0  // Track correct answers

    private var questions: [Question] = [
        Question(
            category: "ENTERTAINMENT: MUSIC",
            text: "Which famous musician is known as the 'King of Pop'?",
            answers: [
                ("Michael Jackson", true),
                ("Elvis Presley", false),
                ("Justin Timberlake", false),
                ("Prince", false),
            ]
        ),
        Question(
            category: "ENTERTAINMENT: MOVIES",
            text: "Which film won the Academy Award for Best Picture in 2024?",
            answers: [
                ("Oppenheimer", true),
                ("Barbie", false),
                ("Poor Things", false),
                ("Killers of the Flower Moon", false),
            ]
        ),
        Question(
            category: "SCIENCE",
            text: "What is the closest planet to the Sun?",
            answers: [
                ("Mercury", true),
                ("Venus", false),
                ("Mars", false),
                ("Earth", false),
            ]
        ),
    ]

    private let questionCounterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private let roundedContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var answerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private func createAnswerButton(title: String, isCorrect: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
        button.tag = isCorrect ? 1 : 0
        return button
    }

    @objc private func answerButtonTapped(_ sender: UIButton) {
        let isCorrect = sender.tag == 1
        sender.backgroundColor = isCorrect ? .green : .red

        // Update score if answer is correct
        if isCorrect {
            correctAnswers += 1
        }

        // Disable all buttons temporarily
        answerStackView.arrangedSubviews.forEach { ($0 as? UIButton)?.isEnabled = false }

        // Wait for 1 second before moving to next question
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.moveToNextQuestion()
        }
    }

    private func moveToNextQuestion() {
        currentQuestionIndex += 1

        // Check if we've reached the end of questions
        if currentQuestionIndex >= questions.count {
            showScoreAlert()
            return
        }

        // Update UI with new question
        updateUI(animated: true)
    }

    private func showScoreAlert() {
        // Calculate percentage
        let percentage = (Double(correctAnswers) / Double(questions.count)) * 100

        // Create score message with emoji based on performance
        let emoji: String
        if percentage == 100 {
            emoji = "🏆"
        } else if percentage >= 66 {
            emoji = "🌟"
        } else if percentage >= 33 {
            emoji = "👍"
        } else {
            emoji = "💪"
        }

        let alert = UIAlertController(
            title: "Quiz Complete! \(emoji)",
            message:
                "Your Score: \(correctAnswers) out of \(questions.count) (\(Int(percentage))%)\n\nWould you like to start over?",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "Start Over", style: .default) { [weak self] _ in
                self?.resetQuiz()
            })

        alert.addAction(UIAlertAction(title: "Close", style: .cancel))

        present(alert, animated: true)
    }

    private func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0  // Reset score
        updateUI(animated: true)
    }

    private func updateUI(animated: Bool = false) {
        let question = questions[currentQuestionIndex]

        // Update labels
        questionCounterLabel.text = "QUESTION: \(currentQuestionIndex + 1)/\(questions.count)"
        categoryLabel.text = question.category
        questionLabel.text = question.text

        // Remove existing answer buttons
        answerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add new answer buttons
        question.answers.forEach { answer in
            let button = createAnswerButton(title: answer.text, isCorrect: answer.isCorrect)
            answerStackView.addArrangedSubview(button)
        }

        if animated {
            // Fade in new content
            let views = [questionLabel, categoryLabel, answerStackView]
            views.forEach { $0.alpha = 0 }

            UIView.animate(withDuration: 0.3) {
                views.forEach { $0.alpha = 1 }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set background color to #6DB0C9
        view.backgroundColor = UIColor(
            red: 109 / 255, green: 176 / 255, blue: 201 / 255, alpha: 1.0)

        setupUI()
        updateUI()

        // Register for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard
            let keyboardSize =
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
                .cgRectValue
        else {
            return
        }

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    private func setupUI() {
        // Add scrollView and contentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Add subviews to contentView
        contentView.addSubview(questionCounterLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(roundedContainerView)
        roundedContainerView.addSubview(questionLabel)
        contentView.addSubview(answerStackView)

        // Setup constraints
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Question counter constraints
            questionCounterLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            questionCounterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            questionCounterLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            questionCounterLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),

            // Category label constraints
            categoryLabel.topAnchor.constraint(
                equalTo: questionCounterLabel.bottomAnchor, constant: 12),
            categoryLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            categoryLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),

            // Rounded container constraints
            roundedContainerView.topAnchor.constraint(
                equalTo: categoryLabel.bottomAnchor, constant: 20),
            roundedContainerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            roundedContainerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),
            roundedContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            // Question label constraints
            questionLabel.topAnchor.constraint(
                equalTo: roundedContainerView.topAnchor, constant: 16),
            questionLabel.bottomAnchor.constraint(
                equalTo: roundedContainerView.bottomAnchor, constant: -16),
            questionLabel.leadingAnchor.constraint(
                equalTo: roundedContainerView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(
                equalTo: roundedContainerView.trailingAnchor, constant: -16),

            // Answer stack view constraints
            answerStackView.topAnchor.constraint(
                equalTo: roundedContainerView.bottomAnchor, constant: 24),
            answerStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            answerStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),
            answerStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)

        // Update layout for new orientation
        coordinator.animate { _ in
            self.view.layoutIfNeeded()
        }
    }
}
