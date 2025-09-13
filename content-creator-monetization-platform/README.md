# Content Creator Monetization Platform

A comprehensive smart contract built on the Stacks blockchain that enables content creators to monetize their work through multiple revenue streams including content sales, subscriptions, and tips.

## 🚀 Features

### For Content Creators
- **Creator Registration**: Register as a content creator with profile customization
- **Content Management**: Create, publish, and manage various types of content (video, audio, image, text, courses)
- **Flexible Pricing**: Set custom prices for content within platform limits (1-1000 STX)
- **Premium Content**: Offer exclusive premium content for subscribers
- **Revenue Streams**:
  - Direct content sales
  - Subscription tiers (Basic, Premium, VIP)
  - Tips from supporters
- **Earnings Withdrawal**: Withdraw accumulated earnings at any time
- **Profile Verification**: Get verified status from platform administrators

### For Users/Supporters
- **Content Discovery**: Browse and purchase content from creators
- **Subscription System**: Subscribe to creators with multiple tier options
- **Tipping**: Support creators with custom tip amounts and messages
- **Content Interaction**: Like and view content
- **Access Control**: Automatic access management for premium content

### Platform Features
- **Revenue Sharing**: 5% platform fee on all transactions
- **Creator Analytics**: Track views, likes, earnings, and subscriber counts
- **Subscription Management**: Automatic subscription expiry and renewal system
- **Security**: Built-in access controls and validation

## 🏗️ Technical Architecture

### Smart Contract Structure

The contract is organized into several key components:

- **Data Storage**: Maps for creators, content, purchases, subscriptions, and analytics
- **Creator Management**: Registration, profile updates, and verification
- **Content System**: Creation, publishing, and access control
- **Monetization**: Purchase, subscription, and tipping mechanisms
- **Analytics**: Comprehensive tracking of creator and platform metrics

### Key Constants
- **Platform Fee**: 5% on all transactions
- **Price Limits**: 1 STX minimum, 1000 STX maximum for content
- **Subscription Tiers**: 
  - Basic: 1 STX/month
  - Premium: 5 STX/month  
  - VIP: 10 STX/month

## 📋 Prerequisites

- Stacks wallet (e.g., Leather, Xverse)
- STX tokens for transactions
- Basic understanding of Stacks blockchain

## 🔧 Installation & Deployment

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/content-creator-platform.git
   cd content-creator-platform
   ```

2. **Install Clarinet** (Stacks development tool)
   ```bash
   # macOS
   brew install clarinet
   
   # Or download from https://github.com/hirosystems/clarinet
   ```

3. **Initialize Clarinet project**
   ```bash
   clarinet new content-platform
   cd content-platform
   ```

4. **Add the contract**
   ```bash
   # Copy the contract code to contracts/content-creator-platform.clar
   ```

5. **Test the contract**
   ```bash
   clarinet test
   ```

### Deployment

1. **Deploy to testnet**
   ```bash
   clarinet deploy --testnet
   ```

2. **Deploy to mainnet**
   ```bash
   clarinet deploy --mainnet
   ```

## 📖 Usage Guide

### For Content Creators

#### 1. Register as a Creator
```clarity
(contract-call? .content-creator-platform register-creator 
  "Creator Name" 
  "Bio description" 
  "https://avatar-url.com/image.jpg")
```

#### 2. Create Content
```clarity
(contract-call? .content-creator-platform create-content
  "Content Title"
  "Content description"
  "video"
  u5000000  ;; 5 STX price
  "https://thumbnail-url.com/thumb.jpg"
  "https://content-url.com/video.mp4"
  false)    ;; Not premium
```

#### 3. Publish Content
```clarity
(contract-call? .content-creator-platform publish-content u1)
```

#### 4. Withdraw Earnings
```clarity
(contract-call? .content-creator-platform withdraw-earnings u1000000)
```

### For Users

#### 1. Purchase Content
```clarity
(contract-call? .content-creator-platform purchase-content u1)
```

#### 2. Subscribe to Creator
```clarity
(contract-call? .content-creator-platform subscribe-to-creator 
  u1        ;; Creator ID
  u1        ;; Premium tier
  u3)       ;; 3 months
```

#### 3. Tip a Creator
```clarity
(contract-call? .content-creator-platform tip-creator
  u1                    ;; Creator ID
  u500000               ;; 0.5 STX tip
  "Great content!")     ;; Message
```

#### 4. View Content
```clarity
(contract-call? .content-creator-platform view-content u1)
```

### Read-Only Functions

#### Get Creator Information
```clarity
(contract-call? .content-creator-platform get-creator u1)
```

#### Check Subscription Status
```clarity
(contract-call? .content-creator-platform is-subscribed 
  'SP1234... u1)
```

#### Get Platform Statistics
```clarity
(contract-call? .content-creator-platform get-platform-stats)
```

## 📊 Data Structures

### Creator Profile
```clarity
{
  owner: principal,
  name: string,
  bio: string,
  avatar-url: string,
  followers: uint,
  total-earnings: uint,
  content-count: uint,
  verification-status: bool,
  created-at: uint,
  tier: uint
}
```

### Content Item
```clarity
{
  creator-id: uint,
  title: string,
  description: string,
  content-type: string,
  price: uint,
  thumbnail-url: string,
  content-url: string,
  views: uint,
  likes: uint,
  earnings: uint,
  is-premium: bool,
  created-at: uint,
  status: string
}
```

## 🔐 Security Features

- **Access Control**: Function-level permissions and ownership validation
- **Input Validation**: Price limits, string length checks, and data validation
- **Reentrancy Protection**: Secure token transfer patterns
- **Error Handling**: Comprehensive error codes and validation

## 🧪 Testing

Run the test suite:
```bash
clarinet test
```

### Test Coverage
- Creator registration and profile management
- Content creation and publishing
- Purchase and subscription workflows
- Tipping functionality
- Access control and permissions
- Edge cases and error conditions

## 🛠️ API Reference

### Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `register-creator` | Register as a content creator | name, bio, avatar-url |
| `create-content` | Create new content | title, description, type, price, urls, premium |
| `purchase-content` | Buy content | content-id |
| `subscribe-to-creator` | Subscribe to creator | creator-id, tier, months |
| `tip-creator` | Send tip to creator | creator-id, amount, message |
| `withdraw-earnings` | Withdraw creator earnings | amount |
| `like-content` | Like content | content-id |
| `view-content` | View content (with access check) | content-id |

### Read-Only Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `get-creator` | Get creator details | creator-id |
| `get-content` | Get content details | content-id |
| `get-subscription` | Get subscription info | subscriber, creator-id |
| `has-purchased-content` | Check purchase status | buyer, content-id |
| `get-creator-stats` | Get creator analytics | creator-id |
| `get-platform-stats` | Get platform statistics | none |

## 📈 Roadmap

- [ ] Mobile app integration
- [ ] Advanced analytics dashboard
- [ ] NFT integration for exclusive content
- [ ] Multi-token support
- [ ] Content recommendation system
- [ ] Creator collaboration features
- [ ] Advanced subscription management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [Wiki](https://github.com/yourusername/content-creator-platform/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/content-creator-platform/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/content-creator-platform/discussions)

## 🙏 Acknowledgments

- Built with [Clarity](https://clarity-lang.org/) smart contract language
- Powered by [Stacks](https://www.stacks.co/) blockchain
- Developed with [Clarinet](https://github.com/hirosystems/clarinet)

---

**⚠️ Disclaimer**: This is experimental software. Use at your own risk. Always test thoroughly before deploying to mainnet.