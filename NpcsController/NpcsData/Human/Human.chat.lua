local talk: {[number]: {
   Content: string, -- What npc gonna say
   Response: string -- Your response
}} = {
   [1] = {
      Content = "Hello, are you okay?",
      Response = "Yes!",
   },
   [2] = {
      Content = "How's your day going?",
      Response = "Great, thanks for asking!",
   },
   [3] = {
      Content = "Do you like coffee or tea?",
      Response = "I prefer tea, how about you?",
   },
   [4] = {
      Content = "What's your favorite color?",
      Response = "I really like blue, it's so calming.",
   },
   [5] = {
      Content = "Have you ever traveled abroad?",
      Response = "Yes, I've been to a few countries. It was an amazing experience!",
   },
   [6] = {
      Content = "What's the last book you read?",
      Response = "I recently finished a mystery novel. It kept me on the edge of my seat!",
   },
   [7] = {
      Content = "How do you stay motivated?",
      Response = "Setting small goals and celebrating achievements helps me stay motivated.",
   },
   [8] = {
      Content = "What's your favorite type of music?",
      Response = "I enjoy listening to a variety of genres, but lately, I've been into indie rock.",
   },
   [9] = {
      Content = "Do you have any pets?",
      Response = "Yes, I have a cat named Luna. She's very playful and cute.",
   },
   [10] = {
      Content = "What's your go-to comfort food?",
      Response = "Pizza is definitely my ultimate comfort food. You can't go wrong with it!",
   },
   [11] = {
      Content = "Are you a morning person or a night owl?",
      Response = "I'm more of a night owl. I find that I'm most productive in the late hours.",
   },
   [12] = {
      Content = "What's your dream vacation destination?",
      Response = "I've always wanted to visit Japan. The culture and history fascinate me.",
   },
   [13] = {
      Content = "Do you enjoy outdoor activities?",
      Response = "Yes, hiking and camping are some of my favorite ways to spend time outdoors.",
   },
   [14] = {
      Content = "How do you handle stress?",
      Response = "I like to practice mindfulness and take short breaks to relax when I'm stressed.",
   },
   [15] = {
      Content = "What's your favorite season?",
      Response = "I love autumn. The cool weather and colorful foliage make it so picturesque.",
   },
   [16] = {
      Content = "Do you have any hidden talents?",
      Response = "I can play the guitar and dabble in photography as well.",
   },
   [17] = {
      Content = "What's your most cherished possession?",
      Response = "A necklace my grandmother gave me. It has sentimental value and reminds me of her.",
   },
   [18] = {
      Content = "How do you approach problem-solving?",
      Response = "I like to break down problems into smaller tasks and tackle them one step at a time.",
   },
   [19] = {
      Content = "What's your favorite movie genre?",
      Response = "I enjoy sci-fi movies. The futuristic concepts always intrigue me.",
   },
   [20] = {
      Content = "Do you have any favorite quotes?",
      Response = "One of my favorites is 'The only way to do great work is to love what you do.'",
   },
   [21] = {
      Content = "What's your guilty pleasure?",
      Response = "I occasionally indulge in binge-watching my favorite TV shows. It's my guilty pleasure.",
   },
   [22] = {
      Content = "How do you stay fit and healthy?",
      Response = "Regular exercise and a balanced diet are key for maintaining my health and well-being.",
   },
   [23] = {
      Content = "What's your proudest achievement?",
      Response = "Completing a challenging project at work and receiving recognition for it was a proud moment.",
   },
   [24] = {
      Content = "Are you a fan of technology?",
      Response = "Absolutely! I love exploring new gadgets and staying updated on the latest tech trends.",
   },
   [25] = {
      Content = "What's your favorite childhood memory?",
      Response = "Going on family vacations to the beach. Those moments are etched in my memory forever.",
   },
   [26] = {
      Content = "How do you like to spend your weekends?",
      Response = "I enjoy a mix of relaxation and adventure. It depends on my mood and energy levels.",
   },
   [27] = {
      Content = "Do you have any hobbies?",
      Response = "I like painting and gardening. They provide a great outlet for my creativity.",
   },
   [28] = {
      Content = "What's your preferred method of communication?",
      Response = "I find face-to-face conversations more meaningful, but I also appreciate the convenience of messaging.",
   },
   [29] = {
      Content = "Do you have any favorite apps on your phone?",
      Response = "I love productivity apps that help me stay organized and focused.",
   },
   [30] = {
      Content = "What's your philosophy on life?",
      Response = "I believe in embracing every moment, learning from experiences, and being grateful for what I have.",
   },
   [31] = {
      Content = "If you could have any superpower, what would it be?",
      Response = "Teleportation would be amazing. Imagine the places I could explore in an instant!",
   },
   [32] = {
      Content = "What's the most interesting place you've ever visited?",
      Response = "Visiting the ancient ruins in Machu Picchu was an unforgettable experience. The history there is incredible.",
   },
   [33] = {
      Content = "Do you have a favorite quote from a book or movie?",
      Response = "One quote I love is from 'The Shawshank Redemption': 'Get busy living or get busy dying.'",
   },
   [34] = {
      Content = "How do you handle change?",
      Response = "I try to embrace it as an opportunity for growth, even though it can be challenging at times.",
   },
   [35] = {
      Content = "What's your favorite way to unwind after a long day?",
      Response = "Listening to calming music and taking a hot bath helps me relax and unwind.",
   },
   [36] = {
      Content = "What's the most adventurous thing you've ever done?",
      Response = "Skydiving was definitely the most adventurous and exhilarating experience of my life.",
   },
   [37] = {
      Content = "Do you have a favorite quote that inspires you?",
      Response = "The quote 'The only limit to our realization of tomorrow will be our doubts of today' always motivates me.",
   },
   [38] = {
      Content = "What's your favorite board game or card game?",
      Response = "I enjoy playing chess. It's a great game of strategy and keeps my mind sharp.",
   },
   [39] = {
      Content = "How do you overcome creative blocks?",
      Response = "Taking a break, going for a walk, or seeking inspiration from different sources helps me overcome creative blocks.",
   },
   [40] = {
      Content = "If you could have dinner with any historical figure, who would it be?",
      Response = "Having dinner with Leonardo da Vinci would be fascinating. His mind was truly ahead of his time.",
   },
   [41] = {
      Content = "What's your favorite dessert?",
      Response = "I have a sweet tooth, so it's hard to choose, but I'd say chocolate lava cake is a top favorite.",
   },
   [42] = {
      Content = "How do you define success?",
      Response = "Success, to me, is finding fulfillment in what you do and making a positive impact on others.",
   },
   [43] = {
      Content = "What's your favorite type of art?",
      Response = "I appreciate abstract art. The freedom of interpretation and expression is truly captivating.",
   },
   [44] = {
      Content = "Do you have a favorite fictional character?",
      Response = "Sherlock Holmes has always been a fascinating character for me. The way he deduces things is incredible.",
   },
   [45] = {
      Content = "How do you stay motivated on challenging days?",
      Response = "I remind myself of the bigger picture and the goals I've set. It helps me push through tough times.",
   },
   [46] = {
      Content = "What's your favorite app for productivity?",
      Response = "I rely on task management apps to keep me organized and productive throughout the day.",
   },
   [47] = {
      Content = "What's your favorite thing about the city you live in?",
      Response = "The cultural diversity and the vibrant arts scene make my city a truly unique and exciting place.",
   },
   [48] = {
      Content = "What's the most valuable lesson life has taught you so far?",
      Response = "Learning to embrace failure as a stepping stone to success has been a valuable lesson for me.",
   },
   [49] = {
      Content = "Do you have a favorite quote about learning?",
      Response = "I love the quote 'Education is the most powerful weapon which you can use to change the world' by Nelson Mandela.",
   },
   [50] = {
      Content = "If you could time travel, where and when would you go?",
      Response = "I would love to witness the Renaissance period in Europe. The art and innovation during that time were extraordinary.",
   },
}

return talk