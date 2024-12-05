library(tidyverse)
library(scales)
library(vangogh)

current_palette = vangogh_palette("StarryNight", 7, "continuous")

#This R code compute the results of the language adherence benchmark.

#The benchmark includes:
##A text coming from one of the collection of Common Corpus. Overall we maintained a ponderated balance across various languages/sources to ensure enough diversity. The benchmark is focused on European languages but not limited to it.
##A start sentence.
##The language as detected by cld3 for the entire text.
##Continuation by base models. All generations are done by vllm under the same parameters: zero temperature and little repetition penalty (1.2).

benchmark = arrow::read_parquet("language_continuation_benchmark.parquet")

#First we pivot the results to get a long dataset.
benchmark = benchmark %>% pivot_longer(pleias_360m:smollm_360m, names_to = "model", values_to = "output")

#We detect the language from the continuation using cld3.
#Basically the main language of the output wins.
#If the model successfully complete the sentence but switch afterwards to another language (usually English), it loses.
benchmark = benchmark %>% mutate(lang_model = detect_language(output))

#We summarize the results. We drop the cases where cld3 is not sure enough about the language.
benchmark_results = benchmark %>% mutate(result = ifelse(text_lang == lang_model, TRUE, FALSE)) %>% filter(!is.na(lang_model))

#We get the final benchmark.
benchmark_results = benchmark_results %>%
  group_by(model, result) %>%
  summarise(total_output = n()) %>%
  mutate(prop = (total_output/sum(total_output))*100) %>%
  filter(result) %>%
  select(-result) %>%
  rename(correct_output = total_output) %>%
  arrange(-prop) %>%
  ungroup()

benchmark_results

benchmark_results %>%
  mutate(model = Hmisc::capitalize(gsub("_", "-", model))) %>%
  ggplot(aes(prop, reorder(model, prop), fill = reorder(model, prop))) +
  geom_col() +
  guides(fill = "none") +
  labs(x="% of correct language continuation", y="Model") +
  theme_classic() +
  scale_x_continuous(limits = c(50, 100), oob=rescale_none) +
  scale_fill_manual(values = current_palette)
