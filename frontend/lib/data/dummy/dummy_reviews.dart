import '../models/review.dart';

final List<Review> dummyReviews = [
  Review(
    id: 'r1',
    authorName: 'Helene Moore',
    authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop&crop=face',
    rating: 4,
    text: 'The dress is great! Very classy and comfortable. It fit perfectly! I\'m 5\'7" and 130 pounds. I am a filtered 34B chest. This dress would be a lovely bridesmaid dress. Pretty!',
    date: DateTime(2024, 6, 13),
    imageUrls: [
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=120&h=120&fit=crop',
      'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=120&h=120&fit=crop',
      'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=120&h=120&fit=crop',
    ],
    helpfulCount: 6,
  ),
  Review(
    id: 'r2',
    authorName: 'Kate Doe',
    authorAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
    rating: 5,
    text: 'I loved this dress so much as soon as I tried it on I knew I had to buy it in another color. I am 5\'4" and wore it with a strapless bra and it stayed up amazingly.',
    date: DateTime(2024, 7, 22),
    helpfulCount: 3,
  ),
  Review(
    id: 'r3',
    authorName: 'Kim Shine',
    authorAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face',
    rating: 5,
    text: 'I love this dress. I would definitely recommend it to anyone looking for a comfortable and cute dress. Very soft material.',
    date: DateTime(2024, 8, 1),
    imageUrls: [
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=120&h=120&fit=crop',
    ],
    helpfulCount: 10,
  ),
  Review(
    id: 'r4',
    authorName: 'Laura R.',
    authorAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop&crop=face',
    rating: 3,
    text: 'It was ok, the material was a bit thin for me but the design is great and shipping was fast.',
    date: DateTime(2024, 9, 5),
    helpfulCount: 1,
  ),
  Review(
    id: 'r5',
    authorName: 'Sofia A.',
    authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop&crop=face',
    rating: 4,
    text: 'Nice quality and true to size. Wore it to a party and got a lot of compliments!',
    date: DateTime(2024, 9, 20),
    helpfulCount: 4,
  ),
];
