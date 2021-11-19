const functions = require("firebase-functions");

const Razorpay = require('razorpay')
const instance = new Razorpay({
    key_id: '',
    key_secret: ''
})

exports.orderApi = functions.region('asia-south1').https.onCall(async(data, context) => {
    var options = {
      amount: data.message,
      currency: "INR",
    };
    try {
        const order = await instance.orders.create(options)
        console.log(order);
        return {
            data: JSON.stringify({
                    order: order,
                    status:"success",
                    key: '', // your razorpay key over here
            })
        }
      } catch(e) {
        console.log(e);
        return {
            data: JSON.stringify({
                    error: e,
                    status: "failure",
            })
        }
      }
});