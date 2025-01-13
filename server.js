const express = require('express');
const cors = require('cors');
const Stripe = require('stripe');

const stripe = new Stripe('sk_test_51QLXl2L0kLdfcs5y98DW4YbvElpIN2OwmA8WEsc7Di4clKVgLGObRBuZQcpfIvZNQ6PsyOrFQk3sRraZI82ksy2n00g7TEFBKn'); // Replace with your secret key

const app = express();
app.use(cors());
app.use(express.json());

app.post('/create-payment-intent', async (req, res) => {
  try {
    const { amount, currency } = req.body;
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency,
    });
    res.send({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});