# Language Adherence Tests

We test [our new suite of language models](https://huggingface.co/collections/PleIAs/common-models-674cd0667951ab7c4ef84cc4) on their language adherence, i.e. how much they are able to continue the generation in the desired output language.

To do this, we use [cld3](https://github.com/google/cld3) to identify the language of the prompt and the language of the generation. We consider the model to exibit language adherence if the language of the prompt and the generation match. We provide the code here (`language_adherence.R`). The dataset used for the evaluation is on [HuggingFace](https://huggingface.co/datasets/PleIAs/Pleias-1.0-eval/blob/main/language_continuation_benchmark.parquet).
