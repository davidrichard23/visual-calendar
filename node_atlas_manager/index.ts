import { FindOptions, MongoClient, ServerApiVersion } from "mongodb";

const pass = encodeURIComponent(""); // Set this
const uri = `mongodb+srv://david:${pass}@cluster0.bhxxrgg.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(uri);

async function run() {
  try {
    const database = client.db("calendar-app-4");
    const col = database.collection("Event");
    const events = await col.updateMany(
      { isTemplate: { $exists: false } },
      { $set: { isTemplate: false } }
    );
    // const events = col.find({ isTemplate: { $exists: false } });
    // console.log(await events.toArray());
  } finally {
    // Ensures that the client will close when you finish/error
    await client.close();
  }
}
run().catch(console.dir);
